# AGENT-11 Mission Library 🎯

## Available Missions

This library contains standardized mission protocols for common development scenarios. Each mission provides a proven execution pattern for multi-agent collaboration.

## MCP Profile Recommendations by Mission

Different missions benefit from different MCP profiles for optimal context usage:

| Mission | Recommended Profile | Reason |
|---------|-------------------|---------|
| connect-mcp | core | Lightweight MCP setup and configuration |
| dev-setup | core | Initial project setup with essential tools |
| dev-alignment | core | Project analysis and understanding |
| mission-build | core or fullstack | Depends on feature requirements |
| mission-fix | core | Bug diagnosis and quick fixes |
| mission-refactor | core | Code improvement and optimization |
| mission-deploy | deployment | Direct Netlify + Railway access |
| mission-document | core | Documentation creation |
| mission-architecture | core | Architecture documentation |
| mission-product-description | core | Product definition and planning |
| mission-mvp | fullstack | Comprehensive toolset for rapid development |
| mission-migrate | database-staging | Safe database migration with read/write access |
| mission-optimize | core | Performance analysis and improvement |
| mission-security | database-production | Read-only production database review |
| mission-integrate | varies | Depends on integration type (payments, deployment, etc.) |
| mission-release | deployment | Deployment and release coordination |
| operation-genesis | core | Intelligence gathering and analysis |
| operation-recon | core | Design reconnaissance |

**Profile Switching**:
```bash
ln -sf .mcp-profiles/[profile].json .mcp.json
# Restart Claude Code
```

See [MCP Profile Guide](../../docs/MCP-GUIDE.md) for complete profile reference.

### Project Setup Missions

#### 🚀 DEV-SETUP - Greenfield Project Initialization
**File**: `dev-setup.md`  
**Purpose**: Initialize new projects with ideation analysis and tracking  
**Duration**: 30-45 minutes  
**Required**: Ideation document (PRD, vision, architecture)  
**Squad**: Coordinator, Strategist, Documenter

#### 🎯 DEV-ALIGNMENT - Existing Project Understanding
**File**: `dev-alignment.md`  
**Purpose**: Align AGENT-11 with existing codebases and establish tracking  
**Duration**: 45-60 minutes  
**Required**: Existing codebase, ideation docs (optional)  
**Squad**: Coordinator, Architect, Developer, Strategist

#### 🔌 CONNECT-MCP - MCP Discovery & Connection
**File**: `connect-mcp.md`  
**Purpose**: Identify, install, and configure required MCP servers based on project needs  
**Duration**: 45-90 minutes  
**Required**: Project requirements, API keys for services  
**Squad**: Coordinator, Strategist, Developer, Tester, Documenter

### Core Development Missions

#### 🏗️ BUILD - New Feature Development
**File**: `mission-build.md`  
**Purpose**: Transform requirements into production-ready features  
**Duration**: 4-8 hours  
**Required**: PRD or requirements document  
**Squad**: Full team engagement

#### 🐛 FIX - Emergency Bug Resolution  
**File**: `mission-fix.md`  
**Purpose**: Rapid bug diagnosis and resolution  
**Duration**: 1-3 hours  
**Required**: Bug report or error details  
**Squad**: Developer, Tester, Analyst

#### ♻️ REFACTOR - Code Improvement
**File**: `mission-refactor.md`  
**Purpose**: Improve code quality without changing functionality  
**Duration**: 2-4 hours  
**Required**: Target files or system area  
**Squad**: Architect, Developer, Tester

#### 🚀 DEPLOY - Production Deployment
**File**: `mission-deploy.md`  
**Purpose**: Prepare and execute production deployment  
**Duration**: 1-2 hours  
**Required**: Tested codebase  
**Squad**: Operator, Tester, Developer

#### 📚 DOCUMENT - Documentation Creation
**File**: `mission-document.md`  
**Purpose**: Create comprehensive documentation  
**Duration**: 2-4 hours  
**Required**: System or feature to document  
**Squad**: Documenter, Developer, Architect

#### 📐 ARCHITECTURE - System Architecture Documentation
**File**: `mission-architecture.md`  
**Purpose**: Create or update comprehensive architecture documentation  
**Duration**: 2-3 hours  
**Required**: Existing codebase or design requirements  
**Squad**: Strategist, Architect, Developer, Documenter

### Strategic Missions

#### 📋 PRODUCT-DESCRIPTION - Product Definition with Risk Management
**File**: `mission-product-description.md`  
**Purpose**: Create comprehensive product description with risk assessment  
**Duration**: 2-3 hours  
**Required**: Product vision or PRD  
**Squad**: Strategist, Analyst, Marketer, Documenter

#### 💡 MVP - Minimum Viable Product
**File**: `mission-mvp.md`  
**Purpose**: Rapid prototype to production MVP  
**Duration**: 1-3 days  
**Required**: Product vision or concept  
**Squad**: Full team engagement

#### 🔄 MIGRATE - System Migration
**File**: `mission-migrate.md`  
**Purpose**: Migrate systems, databases, or platforms  
**Duration**: 4-8 hours  
**Required**: Migration plan or requirements  
**Squad**: Architect, Developer, Operator

#### ⚡ OPTIMIZE - Performance Optimization
**File**: `mission-optimize.md`  
**Purpose**: Improve system performance  
**Duration**: 3-6 hours  
**Required**: Performance metrics or issues  
**Squad**: Architect, Developer, Analyst

#### 🔒 SECURITY - Security Audit & Fixes
**File**: `mission-security.md`  
**Purpose**: Security assessment and remediation  
**Duration**: 4-6 hours  
**Required**: System access for audit  
**Squad**: Architect, Developer, Tester

#### 🔌 INTEGRATE - Third-Party Integration
**File**: `mission-integrate.md`  
**Purpose**: Integrate external services or APIs  
**Duration**: 3-6 hours  
**Required**: API documentation  
**Squad**: Architect, Developer, Tester

#### 🎯 RELEASE - Version Release Management
**File**: `mission-release.md`  
**Purpose**: Coordinate complete product release process  
**Duration**: 2-4 hours  
**Required**: Release scope and timeline  
**Squad**: Coordinator, Developer, Operator, Marketer

### Operations Missions

#### 🔍 GENESIS - Project Reconnaissance
**File**: `operation-genesis.md`  
**Purpose**: Deep reconnaissance and analysis of project requirements  
**Duration**: 1-2 hours  
**Required**: None (self-contained intelligence gathering)  
**Squad**: Coordinator, Strategist, Analyst

#### 🎨 RECON - Design Intelligence
**File**: `operation-recon.md`  
**Purpose**: Design system reconnaissance and UI/UX intelligence gathering  
**Duration**: 1-3 hours  
**Required**: None (autonomous design analysis)  
**Squad**: Coordinator, Designer, Analyst

## Mission Execution Guide

### Starting a Mission

```bash
# Interactive mode - guided mission selection
/coord

# Direct mission with inputs
/coord [mission-name] [input-files...]
```

### Mission Phases

All missions follow a standard phase structure:

1. **Intelligence Gathering** - Understanding requirements
2. **Strategic Planning** - Architecture and approach
3. **Execution** - Implementation by specialists
4. **Validation** - Testing and quality assurance
5. **Deployment** - Production readiness

### Success Criteria

Each mission includes:
- Clear objectives
- Required inputs
- Phase breakdown with time estimates
- Specialist assignments
- Success metrics
- Common variations

## Creating Custom Missions

To create a new mission:

1. Copy `templates/mission-template.md`
2. Define clear phases and specialist roles
3. Add to this library index
4. Test with coordinator

## Mission Best Practices

- Always start with clear requirements
- Let specialists own their domains
- Track progress in project-plan.md
- Document learnings in progress.md
- Iterate based on outcomes

---

## Post-Mission Cleanup Decision

After completing this mission, decide on cleanup approach based on project status:

### ✅ Milestone Transition (Every 2-4 weeks)
**When**: This mission completes a major project milestone, but more work remains.

**Actions** (30-60 min):
1. Extract lessons to `lessons/[category]/` from progress.md
2. Archive current handoff-notes.md to `archives/handoffs/milestone-X/`
3. Clean agent-context.md (retain essentials, archive historical details)
4. Create fresh handoff-notes.md for next milestone
5. Update project-plan.md with next milestone tasks

**See**: `templates/cleanup-checklist.md` Section A for detailed steps

### 🎯 Project Completion (Mission accomplished!)
**When**: All project objectives achieved, ready for new mission.

**Actions** (1-2 hours):
1. Extract ALL lessons from entire progress.md to `lessons/`
2. Create mission archive in `archives/missions/mission-[name]-YYYY-MM-DD/`
3. Update CLAUDE.md with system-level learnings
4. Archive all tracking files (project-plan.md, progress.md, etc.)
5. Prepare fresh start for next mission

**See**: `templates/cleanup-checklist.md` Section B for detailed steps

### 🔄 Continue Active Work (No cleanup needed)
**When**: Mission complete but continuing active development in same phase.

**Actions**: Update progress.md and project-plan.md, continue working.

---

**Reference**: See `project/field-manual/project-lifecycle-guide.md` for complete lifecycle management procedures.

---

*Your mission, should you choose to accept it, begins with `/coord`*