---
name: saas-multitenancy
description: Implement multi-tenancy in SaaS applications — organisation/workspace isolation, row-level security (RLS), tenant routing, role-based access control, and tenant lifecycle management. Use when building tenant, organisation, workspace, RLS, or multi-tenant data-isolation features.
version: 1.0.0
category: database
triggers:
  - multitenancy
  - multi-tenant
  - tenant
  - organization
  - workspace
  - team
  - org
  - tenant isolation
  - data isolation
  - row level security
  - rls
specialist: "@architect"
stack_aware: true
complexity: advanced
estimated_tokens: 4100
dependencies:
  - saas-auth
---

# SaaS Multi-Tenancy

## Capability

Implement robust multi-tenant architecture for SaaS applications with proper data isolation, tenant context management, and scalable patterns. Covers shared database with row-level security, tenant-scoped queries, and organization/team hierarchies.

## Use Cases

- Data isolation between tenants (organizations/workspaces)
- Team/organization hierarchy with roles
- Tenant-scoped API endpoints
- Subdomain or path-based tenant routing
- Tenant provisioning and onboarding
- Cross-tenant admin operations

## When NOT to use this skill

This skill covers shared-database multi-tenancy with row-level security, tenant-scoped queries, and org/team hierarchies. It is not the right fit for:

- **Single-tenant deployments** (one customer per environment, separate DB per customer). RLS-based shared-DB patterns are overkill; use plain auth and treat the database as private.
- **Per-customer database isolation** (fully separate DB instances per tenant). Different patterns; closer to fleet management. Use a multi-DB orchestrator.
- **Per-record customer-managed encryption keys** (BYOK). Adds an orthogonal cryptography layer; the RLS patterns here do not address encryption.
- **Multi-region tenant sharding.** Patterns here assume one logical database. Sharding needs different tooling (Citus, Vitess, custom routing).

## Patterns

### Row-Level Security (RLS) Pattern

**When to use**: Shared database with multiple tenants needing data isolation

**Implementation**: Use database-level RLS policies to enforce tenant isolation. Every query automatically filters by tenant.

```sql
-- Enable RLS on tenant tables
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

-- Create tenant isolation policy
CREATE POLICY tenant_isolation ON projects
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid);

-- Create policy for insert
CREATE POLICY tenant_insert ON projects
  FOR INSERT
  WITH CHECK (tenant_id = current_setting('app.current_tenant_id')::uuid);

-- Create policy for update/delete
CREATE POLICY tenant_modify ON projects
  FOR ALL
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid);
```

```typescript
// Middleware to set tenant context
async function setTenantContext(tenantId: string) {
  // Set session variable for RLS
  await db.execute(
    sql`SELECT set_config('app.current_tenant_id', ${tenantId}, true)`
  );
}

// Usage in API route
async function handleRequest(req: Request) {
  const tenantId = await getTenantFromSession(req);
  await setTenantContext(tenantId);

  // All subsequent queries automatically filtered
  const projects = await db.query.projects.findMany();
  return projects; // Only returns tenant's projects
}
```

### Tenant Context Middleware

**When to use**: Every request needs tenant context for data access

**Implementation**: Extract tenant from subdomain, path, or session and inject into request context.

```typescript
// Tenant context middleware
async function tenantMiddleware(req: Request, next: NextFunction) {
  // Strategy 1: Subdomain (acme.app.com)
  const subdomain = req.headers.host?.split('.')[0];

  // Strategy 2: Path (/org/acme/dashboard)
  const pathTenant = req.url.match(/^\/org\/([^\/]+)/)?.[1];

  // Strategy 3: Session/JWT claim
  const sessionTenant = req.session?.tenantId;

  const tenantSlug = subdomain || pathTenant || sessionTenant;
  if (!tenantSlug) {
    throw new UnauthorizedError('Tenant context required');
  }

  // Resolve tenant
  const tenant = await db.query.tenants.findFirst({
    where: eq(tenants.slug, tenantSlug)
  });

  if (!tenant) {
    throw new NotFoundError('Tenant not found');
  }

  // Inject into request context
  req.tenant = tenant;
  req.tenantId = tenant.id;

  // Set database context for RLS
  await setTenantContext(tenant.id);

  return next();
}
```

### Organization Hierarchy

**When to use**: Tenants with teams, departments, or nested groups

**Implementation**: Create organization → team → member hierarchy with role-based permissions.

```typescript
// Schema for org hierarchy
const organizations = pgTable('organizations', {
  id: uuid('id').primaryKey().defaultRandom(),
  name: text('name').notNull(),
  slug: text('slug').unique().notNull(),
  plan: text('plan').default('free'),
  createdAt: timestamp('created_at').defaultNow()
});

const teams = pgTable('teams', {
  id: uuid('id').primaryKey().defaultRandom(),
  organizationId: uuid('organization_id').references(() => organizations.id),
  name: text('name').notNull(),
  createdAt: timestamp('created_at').defaultNow()
});

const memberships = pgTable('memberships', {
  id: uuid('id').primaryKey().defaultRandom(),
  userId: uuid('user_id').references(() => users.id),
  organizationId: uuid('organization_id').references(() => organizations.id),
  teamId: uuid('team_id').references(() => teams.id),
  role: text('role').notNull(), // 'owner' | 'admin' | 'member'
  createdAt: timestamp('created_at').defaultNow()
});

// Check permission
async function checkPermission(userId: string, orgId: string, requiredRole: string) {
  const membership = await db.query.memberships.findFirst({
    where: and(
      eq(memberships.userId, userId),
      eq(memberships.organizationId, orgId)
    )
  });

  if (!membership) return false;

  const roleHierarchy = { owner: 3, admin: 2, member: 1 };
  return roleHierarchy[membership.role] >= roleHierarchy[requiredRole];
}
```

### Tenant Provisioning

**When to use**: Creating new tenant/organization during signup

**Implementation**: Atomic tenant creation with default resources.

```typescript
async function provisionTenant(
  ownerUserId: string,
  orgName: string
) {
  return await db.transaction(async (tx) => {
    // 1. Generate unique slug
    const baseSlug = slugify(orgName);
    const slug = await generateUniqueSlug(baseSlug);

    // 2. Create organization
    const [org] = await tx.insert(organizations).values({
      name: orgName,
      slug,
      plan: 'free'
    }).returning();

    // 3. Create owner membership
    await tx.insert(memberships).values({
      userId: ownerUserId,
      organizationId: org.id,
      role: 'owner'
    });

    // 4. Create default team
    const [defaultTeam] = await tx.insert(teams).values({
      organizationId: org.id,
      name: 'General'
    }).returning();

    // 5. Add owner to default team
    await tx.update(memberships)
      .set({ teamId: defaultTeam.id })
      .where(
        and(
          eq(memberships.userId, ownerUserId),
          eq(memberships.organizationId, org.id)
        )
      );

    // 6. Initialize default resources
    await initializeDefaultResources(tx, org.id);

    return org;
  });
}
```

## Stack Implementations

### {{stack.frontend.framework}} + {{stack.backend.database}}

**Supabase RLS**:
```sql
-- Supabase-specific RLS with auth.uid()
CREATE POLICY "Users can view own org data" ON projects
  FOR SELECT USING (
    organization_id IN (
      SELECT organization_id FROM memberships
      WHERE user_id = auth.uid()
    )
  );
```

**Prisma Multi-tenant**:
```typescript
// Prisma client extension for tenant scoping
const prismaWithTenant = (tenantId: string) => {
  return prisma.$extends({
    query: {
      $allModels: {
        async $allOperations({ args, query }) {
          args.where = { ...args.where, tenantId };
          return query(args);
        }
      }
    }
  });
};
```

## Exit Criteria

Before declaring this skill's work complete, run each check below and paste the output. "Looks right" is not sufficient. Items marked **gateable** can be wired into `project/gates/` for automated phase-exit checks.

| # | Check | Verification | Pass condition | Gateable |
|---|-------|-------------|----------------|----------|
| 1 | RLS enabled on every tenant-scoped table | `psql -c "SELECT tablename FROM pg_tables WHERE schemaname='public' AND rowsecurity=false AND tablename ~ 'projects\|users\|teams\|memberships'"` (or equivalent for the project DB) | Empty result (every tenant table has RLS on). | yes |
| 2 | Tenant context set before queries | `grep -rEn "setTenantContext\|set_config.*current_tenant" --include="*.ts" --include="*.js" --include="*.py" .` | Match in middleware that runs on every authenticated request. | yes |
| 3 | No tenant ID accepted from request body | `grep -rEn "req\.body\.tenantId\|body\['tenant_id'\]\|request\.body\['tenantId'\]" --include="*.ts" --include="*.js" --include="*.py" .` | Zero matches. Tenant must come from session or auth context. | yes |
| 4 | Background jobs restore tenant context | `grep -rEn "queue.*process\|worker\|job" --include="*.ts" --include="*.js" --include="*.py" . \| grep -L setTenantContext` | Audit list: every job handler calls `setTenantContext` before DB queries. | manual |
| 5 | Cache keys namespaced by tenant | `grep -rEn "cache\.(set\|get)\(['\"]" --include="*.ts" --include="*.js" --include="*.py" . \| grep -v "tenant:"` | Zero matches that don't include tenant in the key. | yes |
| 6 | Tenant slug sanitised | Read tenant-creation handler. | Slug is generated server-side via `slugify`, validated against allowed pattern. | manual |
| 7 | Cross-tenant admin operations explicit | `grep -rEn "admin.*context\|bypass.*rls\|service.*role" --include="*.ts" --include="*.js" --include="*.py" .` | Each occurrence is in an admin-only path with auth check, not generic helper. | manual |
| 8 | Tests prove cross-tenant isolation | `npm test -- --testPathPattern=tenant` or equivalent. | Test where tenant A queries data and gets only tenant A's rows; test where injecting tenant B's ID fails. | yes |

If any check fails, do not declare done. Fix and re-run.

## Anti-Patterns (Excuse / Rebuttal)

### Excuse: "I'll take the tenant ID from the request body; the client knows which tenant they're in."

**Rebuttal**: The client can send any tenant ID, including ones they do not belong to. This is the cross-tenant data leak pattern. Derive tenant from the authenticated session, never from the request body or query string.

```typescript
// WRONG: Client can send any tenant ID
const projects = await getProjects(req.body.tenantId);

// RIGHT: Derive tenant from authenticated session
const tenantId = req.session.tenantId;
const projects = await getProjects(tenantId);
```

### Excuse: "Background jobs run server-side; they don't need tenant context."

**Rebuttal**: They absolutely do, and forgetting it is the second-most-common multi-tenant data leak. A job that queries `analytics` without setting tenant context returns all tenants' analytics, then sends them to one tenant's email. Pass the tenant ID into the job payload, restore the context inside the worker.

```typescript
// WRONG: No tenant context in async job
queue.process('sendReport', async (job) => {
  const data = await db.query.analytics.findMany(); // Gets ALL data!
});

// RIGHT: Pass and restore tenant context
queue.process('sendReport', async (job) => {
  await setTenantContext(job.data.tenantId);
  const data = await db.query.analytics.findMany(); // Tenant-scoped
});
```

### Excuse: "The cache key is the same for every tenant; the data is the same shape."

**Rebuttal**: The shape may be the same; the data is not. Without a tenant namespace, tenant A's dashboard stats serve to tenant B until the TTL expires. Always namespace cache keys by tenant.

```typescript
// WRONG: Cache key collision across tenants
await cache.set('dashboard-stats', stats);

// RIGHT: Namespace cache keys by tenant
await cache.set(`tenant:${tenantId}:dashboard-stats`, stats);
```
