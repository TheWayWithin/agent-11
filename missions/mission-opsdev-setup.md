# Mission: OpsDev Setup ⚙️
## DevOps Environment Configuration

### Mission Type
**Configuration** - Environment and deployment setup

### Estimated Duration
20-30 minutes

### Required Assets
- Existing project codebase (optional but helpful)
- Hosting platform credentials (if applicable)
- Database credentials (if applicable)

---

## Mission Briefing

This mission configures DevOps and environment settings in CLAUDE.md for deployed AGENT-11 users by:
1. Analyzing existing project infrastructure
2. Detecting environment architecture (production, staging, preview)
3. Identifying deployment platforms and configurations
4. Discovering database and service integrations
5. Configuring environment settings in CLAUDE.md

### Prerequisites
- AGENT-11 deployed to project
- Access to project files (.env, configs, etc.)
- Git repository initialized

---

## Execution Protocol

### Phase 1: Infrastructure Discovery (10 min)
```bash
/coord "Analyzing project infrastructure and deployment setup..."
```

**Agent Actions:**
- @architect performs comprehensive infrastructure analysis:

**Step 1: Git Branch Analysis**
```bash
# Detect branch strategy
git branch -a
```
- Check for `develop`, `staging`, `qa`, or custom branches
- Identify current branch
- Map branch strategy pattern:
  - **Two-Environment**: main + develop/staging
  - **Three-Environment**: main + qa + develop
  - **Trunk-Based**: main only
  - **Custom**: Other patterns

**Step 2: Environment File Discovery**
```bash
# Find environment configuration files
ls -la | grep -E "\.env|config"
```
- Locate `.env`, `.env.production`, `.env.staging`, `.env.local`
- Identify environment-specific configs
- Note which environments are configured
- **SECURITY**: Never read actual secrets, only detect presence

**Step 3: Hosting Platform Detection**
```bash
# Check for hosting platform configurations
ls -la netlify.toml vercel.json railway.json render.yaml
cat package.json | grep -E "netlify|vercel|railway|render"
```
- **Netlify**: Check for `netlify.toml`, `_redirects`, `_headers`
- **Vercel**: Check for `vercel.json`, `.vercelignore`
- **Railway**: Check for `railway.json`, `railway.toml`
- **Render**: Check for `render.yaml`
- **Other**: Check package.json scripts for deployment hints

**Step 4: CI/CD Pipeline Discovery**
```bash
# Check for automation configs
ls -la .github/workflows/
```
- GitHub Actions: `.github/workflows/*.yml`
- GitLab CI: `.gitlab-ci.yml`
- CircleCI: `.circleci/config.yml`
- Identify deployment automation patterns

**Step 5: Database & Services Detection**
```bash
# Analyze dependencies and integrations
cat package.json | grep -E "supabase|postgres|mongodb|mysql|stripe|firebase"
```
- **Supabase**: Check for `@supabase/supabase-js`, env vars
- **PostgreSQL**: Check for `pg`, connection strings
- **MongoDB**: Check for `mongoose`, Atlas configs
- **Stripe**: Check for `stripe` package
- **Firebase**: Check for `firebase` configs

**Step 6: Architecture Documentation Review**
- Check if `architecture.md` exists
- Review documented infrastructure if present
- Identify gaps between docs and actual setup

**Analysis Output:**
```markdown
## Infrastructure Analysis

### Branch Strategy
- Pattern: [two-environment | three-environment | trunk-based | custom]
- Branches Detected:
  - main (production)
  - develop (staging) [if exists]
  - Other: [list]

### Hosting Platforms
- Frontend: [Netlify | Vercel | Other | None detected]
- Backend: [Railway | Render | Custom | None detected]
- Config Files: [list found files]

### Database & Services
- Database: [Supabase | PostgreSQL | MongoDB | Other]
- Payment: [Stripe | Other | None]
- Auth: [Supabase | Custom | Other]
- Other Services: [list]

### CI/CD
- Platform: [GitHub Actions | GitLab CI | None]
- Workflows: [list workflow files]
- Deployment Automation: [Yes/No]

### Environment Files
- Production: [.env.production | Yes/No]
- Staging: [.env.staging | Yes/No]
- Local: [.env.local | Yes/No]
- Other: [list]
```

---

### Phase 2: Environment Architecture Mapping (10 min)
```bash
/coord "Mapping environment architecture and deployment workflow..."
```

**Agent Actions:**
- @operator analyzes deployment configuration:

**Environment Detection Logic:**

**If `develop` branch exists:**
```markdown
Detected: Two-Environment Setup
- Production: main branch
- Staging: develop branch
- Preview: feature/* branches (if platform supports)
```

**If `staging` branch exists:**
```markdown
Detected: Two-Environment Setup
- Production: main branch
- Staging: staging branch
- Preview: feature/* branches (if platform supports)
```

**If `qa` or `test` branch exists:**
```markdown
Detected: Three-Environment Setup
- Production: main branch
- QA/Staging: qa/test branch
- Development: develop branch (if exists)
- Preview: feature/* branches
```

**If only `main` exists:**
```markdown
Detected: Trunk-Based Workflow
- Production: main branch only
- Preview: PR branches (if platform supports)
- Recommendation: Consider adding staging environment
```

**Platform-Environment Mapping:**

**Netlify Detection:**
```toml
# Check netlify.toml for context-based deploys
[context.production]  → main branch
[context.develop]     → develop/staging branch
[context.deploy-preview] → PR branches
```

**Railway Detection:**
```bash
# Check for multiple Railway environments
railway environment list
# Or detect from railway.json
```

**Vercel Detection:**
```json
// Check vercel.json or .vercel/project.json
{
  "git": {
    "deploymentEnabled": {
      "main": true,
      "develop": true  // Indicates staging setup
    }
  }
}
```

**Database Environment Detection:**
```bash
# Check for multiple database URLs in env files
# Production: DATABASE_URL or SUPABASE_URL
# Staging: DATABASE_URL_STAGING or separate Supabase project
```

---

### Phase 3: CLAUDE.md Configuration (10 min)
```bash
/coord "Configuring environment settings in CLAUDE.md..."
```

**Agent Actions:**
- @coordinator updates CLAUDE.md with discovered configuration:

**Configuration Template Selection:**

**If Two-Environment Detected:**
```markdown
## Environment Configuration

**Environment Strategy**: two-environment

**Last Updated**: [YYYY-MM-DD]
**Auto-Detected**: Yes [or No if manual]

### Deployment Environments

#### Production
- **Branch**: main
- **URL**: [detected or TBD]
- **Platform**: [Netlify | Vercel | Railway | Other]
- **Deploy Trigger**: Merge to main [or detected workflow]
- **Database**: [Supabase Production | PostgreSQL | Other]
- **Environment File**: .env.production
- **Auto-Deploy**: [Yes/No based on CI/CD detection]

#### Staging
- **Branch**: develop [or detected branch name]
- **URL**: [detected or TBD]
- **Platform**: [Same as production or different]
- **Deploy Trigger**: Merge to develop
- **Database**: [Supabase Staging | Separate instance | Shared]
- **Environment File**: .env.staging
- **Purpose**: QA and validation before production
- **Auto-Deploy**: [Yes/No]

#### Preview (Optional)
- **Branch**: feature/* (any feature branch)
- **URL**: [Platform-specific pattern, e.g., pr-{number}.app.com]
- **Platform**: [Platform] Preview Deploys
- **Deploy Trigger**: Open PR
- **Database**: [Staging database (shared) | Other]
- **Purpose**: PR testing and code review

### Deployment Workflow

**Standard Feature Development:**
1. Create feature branch from develop
2. Open PR to develop → Preview environment auto-deployed (if available)
3. Merge to develop → Staging environment updated
4. Test on staging environment
5. Create PR from develop to main
6. Merge to main → Production deployment

**Hotfix Workflow:**
1. Create hotfix branch from main
2. Implement critical fix
3. Open PR to main (skip staging for critical issues)
4. Merge to main → Production deployment
5. **CRITICAL**: Backport to develop to keep branches in sync
   ```bash
   git checkout develop
   git merge main
   git push
   ```

### Environment Variables

**Production (.env.production)**
- DATABASE_URL: [Provider] Production Database
- API_KEY: Production API keys
- [Other production-specific vars]

**Staging (.env.staging)**
- DATABASE_URL: [Provider] Staging Database
- API_KEY: Staging/Test API keys
- [Other staging-specific vars]

**Local Development (.env.local)**
- DATABASE_URL: Local database or staging
- API_KEY: Development keys
- [Other local vars]

### Hosting Platform Configuration

**Platform**: [Detected Platform]
**Configuration File**: [netlify.toml | vercel.json | etc.]
**Deployment Method**: [Auto-deploy from git | Manual | CI/CD]
**Build Command**: [detected from package.json or config]
**Publish Directory**: [detected]

### Database Configuration

**Provider**: [Supabase | PostgreSQL | MongoDB | Other]
**Production Instance**: [Project ID or connection details]
**Staging Instance**: [Separate project | Same project different schema | None]
**Migration Strategy**: [How migrations are handled]
**Backup Strategy**: [If documented or detected]

### CI/CD Configuration

**Platform**: [GitHub Actions | GitLab CI | None]
**Workflows**:
- [Workflow 1]: [Purpose]
- [Workflow 2]: [Purpose]

**Deployment Automation**:
- Production: [Automatic on merge to main | Manual]
- Staging: [Automatic on merge to develop | Manual]
- Preview: [Automatic on PR | Manual]

### Service Integrations

[List detected services like Stripe, Auth providers, etc.]
- **[Service Name]**: [Purpose] - [Environment-specific setup notes]
```

**If Trunk-Based Detected:**
```markdown
## Environment Configuration

**Environment Strategy**: trunk-based

**Last Updated**: [YYYY-MM-DD]
**Auto-Detected**: Yes

### Deployment Environments

#### Production
- **Branch**: main
- **URL**: [detected or TBD]
- **Platform**: [Detected platform]
- **Deploy Trigger**: Merge to main
- **Database**: [Detected database]
- **Environment File**: .env.production
- **Auto-Deploy**: [Yes/No]

#### Preview
- **Branch**: feature/* (any PR branch)
- **URL**: [Platform preview pattern]
- **Platform**: [Platform] Preview Deploys
- **Deploy Trigger**: Open PR
- **Database**: [Production read-only | Test database]
- **Purpose**: PR testing and validation

### Deployment Workflow

**Feature Development:**
1. Create feature branch from main
2. Open PR to main → Preview deploy (if available)
3. Code review on preview environment
4. Merge to main → Production deployment

**Recommendation**: Consider adding a staging environment for safer deployments:
- Reduces risk of production bugs
- Allows thorough QA before user-facing changes
- See: [link to staging setup guide when available]

[Rest of configuration similar to two-environment template]
```

**If Custom/Complex Detected:**
```markdown
## Environment Configuration

**Environment Strategy**: custom

**Last Updated**: [YYYY-MM-DD]
**Auto-Detected**: Partial (requires manual review)

### Detected Environments

[List all detected branches and potential environments]

**NOTE**: Complex environment setup detected. Please review and customize this configuration.

### Deployment Workflow

[Document detected workflow or mark as TBD for user to fill in]

[Prompt user to review and update configuration]
```

---

## User Interaction Prompts

### If Environment Detection is Ambiguous:

```
I detected the following infrastructure:
- Branches: [list]
- Hosting: [detected]
- Database: [detected]

I'm not certain about your environment strategy. Which setup matches your project?

1. Two-Environment: Production (main) + Staging (develop) + Preview (PRs)
2. Three-Environment: Production + QA + Development
3. Trunk-Based: Production only (main) + Preview (PRs)
4. Custom: Let me describe our setup

[Wait for user response and configure accordingly]
```

### If No Hosting Platform Detected:

```
I couldn't detect a hosting platform configuration. How is this project deployed?

1. Netlify
2. Vercel
3. Railway
4. Render
5. Custom/Other
6. Not deployed yet (local development only)

[Wait for response]

[If platform selected:]
"Would you like me to help set up [Platform] configuration files?"
```

### If Database Configuration Unclear:

```
I detected [database type] in dependencies, but couldn't determine environment setup.

Do you use separate databases for production and staging?

1. Yes - Separate database instances (recommended)
2. No - Same database for all environments
3. No database yet / Local only

[Configure based on response]
```

---

## Success Metrics

✅ **Mission Complete When:**
- [ ] Infrastructure fully analyzed
- [ ] Environment architecture detected/configured
- [ ] Branch strategy documented
- [ ] Hosting platform configuration documented
- [ ] Database setup documented
- [ ] Environment configuration added to CLAUDE.md
- [ ] Deployment workflow documented
- [ ] Service integrations identified

---

## Post-Mission Checklist

1. **Verify Configuration:**
   - Review CLAUDE.md environment section
   - Ensure all detected platforms are documented
   - Confirm environment mappings are correct

2. **Test Understanding:**
   - Ask @operator: "Which environment does the develop branch deploy to?"
   - Verify agents can correctly identify deployment targets

3. **Commit Configuration:**
   ```bash
   git add CLAUDE.md
   git commit -m "⚙️ Configure OpsDev environment settings"
   git push
   ```

4. **Optional: Update Architecture Docs:**
   - If architecture.md exists, ensure deployment architecture is documented
   - Add infrastructure diagrams if helpful

---

## Troubleshooting

### No Environment Files Detected
- **Issue**: No .env files found
- **Solution**: Ask user if environment variables are managed elsewhere (hosting platform dashboard, CI/CD secrets)
- **Action**: Document where environment variables are configured

### Multiple Hosting Platforms Detected
- **Issue**: Both Netlify and Vercel configs present
- **Solution**: Ask user which is active
- **Action**: Document primary platform, note secondary as legacy/backup

### Branch Strategy Unclear
- **Issue**: Unusual branch names or patterns
- **Solution**: Ask user to describe their git workflow
- **Action**: Document custom workflow with user input

### No Database Detected
- **Issue**: No database dependencies or configs found
- **Solution**: Ask if project uses external services or is frontend-only
- **Action**: Document as "No database" or "External API only"

### CI/CD Detected But No Branch Mapping
- **Issue**: GitHub Actions exist but don't specify environments
- **Solution**: Review workflow files for deployment triggers
- **Action**: Document detected automation, note if environment mapping is unclear

---

## Related Missions
- **Dev-Setup** - Initial greenfield project setup
- **Dev-Alignment** - Existing project understanding
- **Deploy** - Executing deployments based on this configuration

---

## Command Reference

```bash
# Run OpsDev setup mission
/coord opsdev-setup

# Run with specific focus
/coord opsdev-setup --focus hosting
/coord opsdev-setup --focus database

# Skip detection and configure manually
/coord opsdev-setup --manual

# Update existing configuration
/coord opsdev-setup --update
```

---

## Configuration Examples

### Example 1: Supabase + Netlify Two-Environment

```markdown
## Environment Configuration

**Environment Strategy**: two-environment

### Deployment Environments

#### Production
- Branch: main
- URL: https://app.example.com
- Platform: Netlify
- Database: Supabase Production (project: abc-prod)
- Environment File: .env.production

#### Staging
- Branch: develop
- URL: https://develop.example.com
- Platform: Netlify (branch deploy)
- Database: Supabase Staging (project: abc-staging)
- Environment File: .env.staging
```

### Example 2: Railway + PostgreSQL Three-Environment

```markdown
## Environment Configuration

**Environment Strategy**: three-environment

### Deployment Environments

#### Production
- Branch: main
- Platform: Railway (environment: production)
- Database: Railway PostgreSQL Production

#### QA
- Branch: qa
- Platform: Railway (environment: qa)
- Database: Railway PostgreSQL QA

#### Development
- Branch: develop
- Platform: Railway (environment: development)
- Database: Railway PostgreSQL Development
```

### Example 3: Trunk-Based with Vercel

```markdown
## Environment Configuration

**Environment Strategy**: trunk-based

### Deployment Environments

#### Production
- Branch: main
- URL: https://app.vercel.app
- Platform: Vercel
- Database: Supabase Production
- Auto-Deploy: Yes

#### Preview
- Branch: feature/* (PRs)
- URL: Dynamic (pr-{number}.vercel.app)
- Platform: Vercel Preview Deploys
- Database: Staging database (shared)
```

---

## Security Considerations

### Environment Variable Safety
- ❌ **NEVER** read or log actual secret values
- ✅ **ONLY** detect presence of environment files
- ✅ **DOCUMENT** which variables are needed, not their values
- ✅ **RECOMMEND** using platform secret management

### Database Access
- ❌ **DON'T** include connection strings in CLAUDE.md
- ✅ **DO** document which environment uses which database
- ✅ **RECOMMEND** separate databases for production/staging
- ✅ **WARN** if production credentials might be shared

### Best Practices
- Production and staging should use separate database instances
- Never use production data in staging (use anonymized/synthetic data)
- Environment variables should be managed in hosting platform dashboards
- Secrets should never be committed to git

---

## Future Enhancements

**Planned Features:**
- Auto-detect Supabase branching feature usage
- Railway environment linking validation
- CI/CD workflow generation based on setup
- Environment variable validation (warn if DATABASE_URL looks like production in staging)

---

*"Know your infrastructure before you deploy."* - AGENT-11 Field Manual
