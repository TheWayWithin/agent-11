# Stack Profiles

Stack profiles define your project's technology choices, enabling AGENT-11 skills to generate stack-specific code and guidance.

## Quick Start

1. **Choose a profile** from this directory (or create your own)
2. **Copy to your project root**: `cp nextjs-supabase.yaml stack-profile.yaml`
3. **Customize** the interpolation values with your project-specific settings
4. **Skills auto-adapt** to your stack when loaded

## Available Profiles

| Profile | Frontend | Backend | Database | Best For |
|---------|----------|---------|----------|----------|
| `nextjs-supabase` | Next.js 14 | Edge/Vercel | Supabase | MVPs, SaaS, Real-time |
| `remix-railway` | Remix 2 | Node.js/Railway | PostgreSQL | High traffic, API-first |
| `sveltekit-supabase` | SvelteKit 2 | Node.js | Supabase | Performance-critical |

## Profile Structure

```yaml
name: "profile-name"           # Kebab-case identifier
display_name: "Display Name"   # Human-readable name
description: "..."             # What this stack is good for
version: "1.0.0"

recommended_for:               # Project types this stack suits
  - mvp
  - saas

frontend:                      # Frontend technology choices
  framework: nextjs
  styling: tailwindcss
  # ... more options

backend:                       # Backend technology choices
  runtime: edge
  database: supabase
  # ... more options

services:                      # External service integrations
  payments: stripe
  email: resend
  # ... more options

deployment:                    # Hosting and CI/CD
  frontend: vercel
  ci_cd: github_actions

development:                   # Dev tooling preferences
  language: typescript
  package_manager: pnpm
  testing:
    unit: vitest
    e2e: playwright

interpolation:                 # Custom values for skills
  project_name: "MyApp"
  # ... project-specific values
```

## How Skills Use Stack Profiles

Skills use `{{stack.*}}` interpolation to adapt to your stack:

```typescript
// In skill template (stack-agnostic):
// {{stack.frontend.framework}} authentication setup

// With nextjs-supabase profile, becomes:
// nextjs authentication setup

// With remix-railway profile, becomes:
// remix authentication setup
```

### Interpolation Examples

| Variable | nextjs-supabase | remix-railway |
|----------|-----------------|---------------|
| `{{stack.frontend.framework}}` | `nextjs` | `remix` |
| `{{stack.backend.database}}` | `supabase` | `postgres` |
| `{{stack.backend.orm}}` | `supabase_client` | `prisma` |
| `{{stack.services.payments}}` | `stripe` | `stripe` |
| `{{stack.deployment.frontend}}` | `vercel` | `railway` |

## Creating Custom Profiles

### 1. Start from a Template

```bash
cp templates/stack-profiles/nextjs-supabase.yaml my-stack.yaml
```

### 2. Customize Technology Choices

Edit each section to match your preferred stack. See the schema for all available options:

```bash
# View all available options
cat project/schemas/stack-profile.schema.yaml
```

### 3. Add Project-Specific Values

Update the `interpolation` section with your actual values:

```yaml
interpolation:
  project_name: "ActualProjectName"
  supabase_url: "https://abc123.supabase.co"
  stripe_publishable_key: "pk_test_..."
```

### 4. Validate Your Profile

```bash
# Validate against schema (requires yq or similar)
yq eval 'true' my-stack.yaml && echo "Valid YAML"
```

## Stack Selection Guide

### Choose Next.js + Supabase if:
- You want the fastest path to MVP
- You need real-time features
- Your team knows React
- You prefer managed services (less ops)
- You're targeting Vercel deployment

### Choose Remix + Railway if:
- You need full Node.js runtime capabilities
- You prefer traditional server-side architecture
- You want more control over your database
- You're building an API-heavy application
- You need progressive enhancement

### Choose SvelteKit + Supabase if:
- Performance is your top priority
- You want smaller bundle sizes
- Your team is open to learning Svelte
- You value developer experience
- You're building a content-heavy site

## Extending Profiles

### Adding Custom Services

If you need a service not in the schema, add it to `interpolation`:

```yaml
interpolation:
  custom_api_url: "https://api.custom-service.com"
  custom_api_key: "sk_..."
```

Then reference in skills as `{{stack.interpolation.custom_api_url}}`.

### Team-Specific Profiles

Create profiles that match your team's conventions:

```yaml
# my-team-stack.yaml
name: "my-team-standard"
description: "Our team's standard stack configuration"

development:
  package_manager: yarn  # Our team uses yarn
  linting: biome        # We prefer Biome
  testing:
    e2e: cypress        # We use Cypress, not Playwright
```

## Common Customizations

### Switching Auth Providers

```yaml
# From Supabase Auth to Clerk
backend:
  auth_provider: clerk  # Was: supabase_auth
```

### Adding Real-time

```yaml
services:
  realtime: pusher  # Or: supabase_realtime, ably, socket_io
```

### Changing Hosting

```yaml
deployment:
  frontend: netlify  # Was: vercel
  backend: railway   # Was: same_as_frontend
```

## Schema Reference

See `project/schemas/stack-profile.schema.yaml` for:
- All available fields and their types
- Valid enum values for each option
- Required vs optional fields
- Complete examples

## Troubleshooting

### "Unknown stack value" errors
- Ensure your profile value matches a schema enum exactly
- Check for typos in field names
- Verify YAML syntax is valid

### Skills not adapting to stack
- Verify stack profile is in the correct location
- Check that skill has `stack_aware: true` in frontmatter
- Ensure interpolation variables are spelled correctly

### Missing interpolation values
- Skills will use `[STACK_VALUE]` placeholder if value missing
- Add missing values to your profile's `interpolation` section
- Or set `fail_on_missing: false` in loading config
