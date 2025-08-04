# AGENT-11 Mission Library 🎯

## Available Missions

This library contains standardized mission protocols for common development scenarios. Each mission provides a proven execution pattern for multi-agent collaboration.

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

### Strategic Missions

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

*Your mission, should you choose to accept it, begins with `/coord`*