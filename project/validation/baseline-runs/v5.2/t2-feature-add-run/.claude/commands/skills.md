---
name: skills
description: Discover and manage SaaS skills available for your project
version: 1.0.0
---

# SaaS Skills Discovery

You are executing the `/skills` command to help the user discover and manage available SaaS skills.

## Command Variants

**`/skills`** - List all available skills with summaries
**`/skills [skill-name]`** - Show detailed info for a specific skill
**`/skills match [task]`** - Find skills matching a task description
**`/skills stack`** - Show current stack profile and compatible skills

## Execution Protocol

### 1. Discover Available Skills

**Search for skills in these locations** (in order):
1. `project/skills/*/SKILL.md` - Library skills (deployed with AGENT-11)
2. `skills/*/SKILL.md` - User/project-specific skills

```bash
# Find all SKILL.md files
find . -name "SKILL.md" -type f 2>/dev/null | head -20
```

### 2. Parse Skill Frontmatter

For each SKILL.md found, extract:
- `name` - Skill identifier
- `version` - Skill version
- `category` - Category (authentication, payments, database, etc.)
- `triggers` - Keywords that activate this skill
- `specialist` - Which agent uses this skill (@developer, @architect, etc.)
- `complexity` - beginner, intermediate, advanced
- `estimated_tokens` - Context size
- `dependencies` - Other skills required

### 3. Command Responses

#### `/skills` (List All)

Output format:
```markdown
## Available SaaS Skills

| Skill | Category | Specialist | Triggers | Tokens |
|-------|----------|------------|----------|--------|
| saas-auth | authentication | @developer | auth, login, oauth | ~3800 |
| saas-payments | payments | @developer | stripe, checkout | ~4200 |
| saas-multitenancy | database | @architect | tenant, org, rls | ~4100 |
| saas-billing | payments | @developer | billing, plan, quota | ~3900 |
| saas-email | communication | @developer | email, resend | ~3200 |
| saas-onboarding | infrastructure | @developer | onboarding, wizard | ~3500 |
| saas-analytics | analytics | @analyst | analytics, tracking | ~3600 |

**Usage**:
- Skills auto-load when coordinator detects trigger keywords in task descriptions
- Use `/skills [name]` for detailed skill info
- Use `/skills match "your task"` to find relevant skills
```

#### `/skills [skill-name]` (Skill Details)

Read the full SKILL.md and output:
```markdown
## Skill: saas-auth

**Version**: 1.0.0
**Category**: authentication
**Specialist**: @developer
**Complexity**: intermediate
**Estimated Tokens**: ~3800

### Triggers
auth, authentication, login, signup, sign up, sign in, password, session, jwt, oauth, social login, google login, github login, email verification, password reset, magic link

### Dependencies
None

### Capability
[Brief capability description from SKILL.md]

### Key Patterns
- Email/Password Authentication
- OAuth/Social Login
- Session Management
- Password Reset Flow
- Rate Limiting

### Quality Checklist Items
- [ ] Password hashed with bcrypt (cost factor 12+)
- [ ] Email verification before full access
- [ ] Session uses httpOnly, secure, sameSite cookies
- [ ] Rate limiting on auth endpoints
... [truncated for display]

### Use This Skill
The coordinator will automatically load this skill when your task includes trigger keywords.

Example:
> "Implement user authentication with Google OAuth"
→ saas-auth skill auto-loaded for @developer
```

#### `/skills match [task]` (Find Matching Skills)

Parse the task description and match against skill triggers:

```markdown
## Skills Matching: "Set up user login with Stripe billing"

### Matched Skills (by relevance)

1. **saas-auth** (3 trigger matches: login, user, authentication)
   - Handles: User authentication flows
   - Specialist: @developer

2. **saas-payments** (2 trigger matches: stripe, billing)
   - Handles: Stripe payment integration
   - Specialist: @developer

3. **saas-billing** (1 trigger match: billing)
   - Handles: Subscription management
   - Specialist: @developer

### Recommended Loading
For this task, coordinator should load: `saas-auth` + `saas-payments`
Total token budget: ~8000 tokens

### Trigger Command
```
/coord build "Set up user login with Stripe billing"
```
The coordinator will auto-load matched skills when delegating.
```

#### `/skills stack` (Stack Profile Info)

Check for stack profile and show compatibility:

```markdown
## Current Stack Profile

**Profile**: nextjs-supabase (v1.0.0)
**Location**: ./stack-profile.yaml

### Stack Configuration
| Category | Choice |
|----------|--------|
| Frontend | Next.js 14 |
| Database | Supabase |
| Auth | Supabase Auth |
| Payments | Stripe |
| Email | Resend |

### Skill Compatibility
All 7 SaaS skills support this stack profile.

Skills will use these interpolations:
- `{{stack.frontend.framework}}` → nextjs
- `{{stack.backend.database}}` → supabase
- `{{stack.backend.auth_provider}}` → supabase_auth

### Available Profiles
- nextjs-supabase (current)
- remix-railway
- sveltekit-supabase

To switch profiles:
```bash
cp templates/stack-profiles/remix-railway.yaml stack-profile.yaml
```
```

If no stack profile exists:
```markdown
## Stack Profile Not Found

No `stack-profile.yaml` found in project root.

### Quick Setup
1. Choose a profile from templates:
   - `nextjs-supabase` - Next.js 14 + Supabase (recommended for MVPs)
   - `remix-railway` - Remix + Railway + PostgreSQL
   - `sveltekit-supabase` - SvelteKit + Supabase

2. Copy to project root:
   ```bash
   cp templates/stack-profiles/nextjs-supabase.yaml stack-profile.yaml
   ```

3. Customize interpolation values in `stack-profile.yaml`

Skills will work without a stack profile, but won't have stack-specific implementations.
```

## Error Handling

**No skills found**:
```markdown
## No Skills Found

No SKILL.md files found in:
- project/skills/*/SKILL.md
- skills/*/SKILL.md

This may mean:
1. AGENT-11 skills not installed (run install script)
2. Looking in wrong directory

To install AGENT-11 skills:
```bash
./install.sh
```
```

**Invalid skill name**:
```markdown
## Skill Not Found: [name]

The skill "[name]" was not found.

Available skills:
- saas-auth
- saas-payments
- saas-multitenancy
- saas-billing
- saas-email
- saas-onboarding
- saas-analytics

Use `/skills` to list all available skills.
```
