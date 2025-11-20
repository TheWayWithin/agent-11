# File Persistence Regression Test Suite

**Purpose**: Validate Sprint 1 file persistence hardening enhancements and provide baseline for Sprint 2 comparison

**Last Updated**: 2025-01-19
**Sprint**: 1 (Phases 1A-1D)
**Target**: Coordinator delegation protocol compliance and file persistence success rate

---

## Test Environment

**Prerequisites**:
- AGENT-11 development environment active
- Test workspace: `/Users/jamiewatters/DevProjects/agent-11/test-workspace/`
- Coordinator agent active with Task tool access
- All 5 affected specialists deployed (developer, tester, architect, designer, documenter)

**Setup Commands**:
```bash
# Create clean test workspace
mkdir -p /Users/jamiewatters/DevProjects/agent-11/test-workspace
cd /Users/jamiewatters/DevProjects/agent-11/test-workspace

# Clean any previous test files
rm -rf ./*

# Verify clean state
ls -la
# Expected: Empty directory (only . and ..)
```

---

## Test Category 1: Single File Creation

### Test 1.1: Single TypeScript File

**Scenario**: Coordinator delegates creation of single .ts file to @developer

**Execution**:
```
Coordinator prompt: "Delegate to @developer to create test-single.ts
with a simple TypeScript function that adds two numbers."
```

**Expected Developer Response**:
```json
{
  "file_creation_request": {
    "file_path": "/Users/jamiewatters/DevProjects/agent-11/test-workspace/test-single.ts",
    "content": "export function add(a: number, b: number): number {\n  return a + b;\n}\n"
  }
}
```

**Coordinator Verification Protocol**:
```bash
# Pre-verification
ls -lh test-single.ts 2>&1
# Expected: "No such file or directory"

# Coordinator executes Write tool
# [Write tool execution with developer's content]

# Post-verification
ls -lh test-single.ts
# Expected: File exists, size ~80 bytes

# Content verification
cat test-single.ts
# Expected: Exact content matches developer specification

# Documentation
echo "✅ test-single.ts verified: $(date)" >> ../progress.md
```

**Success Criteria**:
- ✅ Developer provides structured output (no Write attempts)
- ✅ Coordinator executes pre-verification
- ✅ Coordinator uses Write tool with developer's content
- ✅ Coordinator executes post-verification
- ✅ File persists and matches specification
- ✅ Verification timestamp documented

**Baseline Comparison**:
- **Before Sprint 1**: ~30% success rate (file may not persist)
- **After Sprint 1**: Target >80% success rate
- **Sprint 2**: Target >95% success rate (coordinator-as-executor)

---

### Test 1.2: Single Markdown Documentation File

**Scenario**: Coordinator delegates creation of single .md file to @documenter

**Execution**:
```
Coordinator prompt: "Delegate to @documenter to create README-test.md
with sections for Overview, Installation, and Usage."
```

**Expected Documenter Response**:
```markdown
**File Path**: /Users/jamiewatters/DevProjects/agent-11/test-workspace/README-test.md

**Content**:
# Test Project

## Overview
This is a test project for file persistence validation.

## Installation
No installation required for testing.

## Usage
Run tests to validate file creation protocols.
```

**Coordinator Verification Protocol**:
```bash
# Pre-verification
ls -lh README-test.md 2>&1
# Expected: "No such file or directory"

# Coordinator executes Write tool
# [Write tool execution]

# Post-verification
ls -lh README-test.md
# Expected: File exists, size ~200 bytes

# Content verification
head -n 10 README-test.md
# Expected: Contains "# Test Project" header

# Documentation
echo "✅ README-test.md verified: $(date)" >> ../progress.md
```

**Success Criteria**: Same as Test 1.1

---

## Test Category 2: Multiple File Creation

### Test 2.1: Three Related Files (Module System)

**Scenario**: Coordinator delegates creation of 3 related TypeScript files to @developer

**Execution**:
```
Coordinator prompt: "Delegate to @developer to create a TypeScript module
with index.ts, types.ts, and utils.ts files in test-workspace."
```

**Expected Developer Response**:
```json
{
  "files": [
    {
      "path": "/Users/jamiewatters/DevProjects/agent-11/test-workspace/index.ts",
      "content": "export * from './types';\nexport * from './utils';\n"
    },
    {
      "path": "/Users/jamiewatters/DevProjects/agent-11/test-workspace/types.ts",
      "content": "export interface User {\n  id: string;\n  name: string;\n}\n"
    },
    {
      "path": "/Users/jamiewatters/DevProjects/agent-11/test-workspace/utils.ts",
      "content": "export function formatName(name: string): string {\n  return name.toUpperCase();\n}\n"
    }
  ]
}
```

**Coordinator Verification Protocol**:
```bash
# Pre-verification (all files)
ls -lh index.ts types.ts utils.ts 2>&1
# Expected: All "No such file or directory"

# Coordinator executes Write tool for each file
# [3 Write tool executions]

# Post-verification (batch)
ls -lh index.ts types.ts utils.ts
# Expected: All 3 files exist with sizes > 0

# Content verification (sample)
head -n 3 types.ts
# Expected: Contains "export interface User"

# Documentation
echo "✅ 3 files verified: $(date)" >> ../progress.md
```

**Success Criteria**:
- ✅ Developer provides structured output for all 3 files
- ✅ Coordinator verifies all files don't exist pre-creation
- ✅ Coordinator creates all 3 files
- ✅ Coordinator verifies all 3 files exist post-creation
- ✅ All 3 files persist and match specifications
- ✅ Single verification timestamp for batch

**Baseline Comparison**:
- **Before Sprint 1**: ~10% success rate for 3 files (usually 0-1 persist)
- **After Sprint 1**: Target >60% success rate for all 3 files
- **Sprint 2**: Target >90% success rate for all 3 files

---

## Test Category 3: Nested Directory Creation

### Test 3.1: Multi-Level Directory Structure

**Scenario**: Coordinator delegates creation of files in nested directories to @architect

**Execution**:
```
Coordinator prompt: "Delegate to @architect to create src/core/types.ts
and src/utils/helpers.ts with TypeScript interfaces and utility functions."
```

**Expected Architect Response**:
```json
{
  "files": [
    {
      "path": "/Users/jamiewatters/DevProjects/agent-11/test-workspace/src/core/types.ts",
      "content": "export interface Config {\n  apiKey: string;\n  debug: boolean;\n}\n"
    },
    {
      "path": "/Users/jamiewatters/DevProjects/agent-11/test-workspace/src/utils/helpers.ts",
      "content": "export function log(message: string): void {\n  console.log(message);\n}\n"
    }
  ],
  "directories_required": [
    "src/core",
    "src/utils"
  ]
}
```

**Coordinator Verification Protocol**:
```bash
# Pre-verification (directories and files)
ls -R src/ 2>&1
# Expected: "No such file or directory"

# Create directories first
mkdir -p src/core src/utils

# Verify directories created
ls -ld src/core src/utils
# Expected: Both directories exist

# Coordinator executes Write tool for each file
# [2 Write tool executions]

# Post-verification (nested structure)
find src -type f -name "*.ts"
# Expected: 2 files found

ls -lh src/core/types.ts src/utils/helpers.ts
# Expected: Both files exist

# Content verification
cat src/core/types.ts
# Expected: Contains Config interface

# Documentation
echo "✅ Nested structure verified: $(date)" >> ../progress.md
```

**Success Criteria**:
- ✅ Architect specifies directory requirements
- ✅ Coordinator creates directories before files
- ✅ Coordinator verifies directory creation
- ✅ Files created in correct nested locations
- ✅ All files persist with correct paths
- ✅ find command confirms structure

---

## Test Category 4: File Edit Operations

### Test 4.1: Content Modification

**Scenario**: Coordinator delegates modification of existing file to @developer

**Setup**:
```bash
# Create initial file
echo "export const VERSION = '1.0.0';" > version.ts
```

**Execution**:
```
Coordinator prompt: "Delegate to @developer to update version.ts
to change VERSION to '1.1.0' and add BUILD_DATE constant."
```

**Expected Developer Response**:
```markdown
I cannot edit files directly. Here's the updated content for version.ts:

**File Path**: /Users/jamiewatters/DevProjects/agent-11/test-workspace/version.ts

**Updated Content**:
export const VERSION = '1.1.0';
export const BUILD_DATE = '2025-01-19';
```

**Coordinator Verification Protocol**:
```bash
# Pre-verification (existing content)
cat version.ts
# Expected: VERSION = '1.0.0' only

# Coordinator executes Write tool (overwrites existing)
# [Write tool execution]

# Post-verification (updated content)
cat version.ts
# Expected: VERSION = '1.1.0' and BUILD_DATE present

# Verify both constants exist
grep "VERSION = '1.1.0'" version.ts
grep "BUILD_DATE" version.ts
# Expected: Both found

# Documentation
echo "✅ version.ts edit verified: $(date)" >> ../progress.md
```

**Success Criteria**:
- ✅ Developer provides complete updated content
- ✅ Coordinator verifies existing content first
- ✅ Coordinator overwrites with updated content
- ✅ File persists with modifications
- ✅ Verification confirms both old and new elements

---

## Test Category 5: Complex Scenarios

### Test 5.1: Multi-Specialist Collaboration

**Scenario**: Coordinator orchestrates file creation across 3 specialists in sequence

**Execution**:
```
1. @architect creates architecture.md (system design)
2. @developer creates implementation.ts (based on architecture)
3. @tester creates tests.spec.ts (based on implementation)
```

**Coordinator Verification Protocol**:
```bash
# Phase 1: Architecture
# [Delegate, verify, create architecture.md]
ls -lh architecture.md
echo "✅ Phase 1 complete: $(date)" >> ../progress.md

# Phase 2: Implementation (depends on Phase 1)
# [Delegate, verify, create implementation.ts]
ls -lh implementation.ts
echo "✅ Phase 2 complete: $(date)" >> ../progress.md

# Phase 3: Testing (depends on Phase 2)
# [Delegate, verify, create tests.spec.ts]
ls -lh tests.spec.ts
echo "✅ Phase 3 complete: $(date)" >> ../progress.md

# Final verification (all 3 files)
ls -lh architecture.md implementation.ts tests.spec.ts
# Expected: All 3 files exist

# Documentation
echo "✅ 3-phase collaboration verified: $(date)" >> ../progress.md
```

**Success Criteria**:
- ✅ All 3 specialists provide structured output
- ✅ Coordinator verifies each phase independently
- ✅ Dependencies maintained (architecture → implementation → tests)
- ✅ All 3 files persist
- ✅ Content cross-references verified
- ✅ Phase timestamps documented

---

## Success Metrics Framework

### Metric 1: Coordinator Protocol Compliance Rate

**Definition**: Percentage of file creation tasks where coordinator follows mandatory protocol

**Calculation**:
```
Compliance Rate = (Tasks with full protocol / Total file creation tasks) × 100%

Full protocol includes:
1. Pre-verification (ls before Write)
2. Write tool execution
3. Post-verification (ls + content check)
4. Verification timestamp in progress.md
5. Task marked [x] only after verification
```

**Target**: >95% compliance rate

---

### Metric 2: File Persistence Success Rate

**Definition**: Percentage of delegated file creations that result in persisted files

**Calculation**:
```
Persistence Rate = (Files verified on filesystem / Files delegated) × 100%
```

**Target**: >80% persistence rate (Sprint 1), >95% (Sprint 2)
**Baseline**: ~30% (before Sprint 1 enhancements)

---

### Metric 3: Specialist Compliance Rate

**Definition**: Percentage of specialists that comply with FILE CREATION LIMITATION protocol

**Target**: 100% compliance rate (5/5 specialists)

**Measurement**:
- Acknowledges "cannot create files directly"
- Provides structured output (file path + content)
- Suggests coordinator delegation

---

### Metric 4: Protocol Violation Rate

**Definition**: Number of protocol violations per 100 file creation tasks

**Target**: <5 violations per 100 tasks

**Violations include**:
- Specialist attempts direct file creation
- Coordinator skips verification
- Coordinator marks [x] before verification
- File creation without documentation

---

## Test Execution Schedule

### Phase 1: Baseline Establishment (Week 1)

**Day 1-2**: Single file tests
- Run Tests 1.1, 1.2 (5 iterations each)
- Collect persistence rate data

**Day 3-4**: Multiple file tests
- Run Tests 2.1, 2.2 (3 iterations each)
- Measure multi-file success rate

**Day 5**: Nested directory tests
- Run Test 3.1 (3 iterations)
- Verify directory handling

### Phase 2: Compliance Validation (Week 2)

**Day 1**: Specialist compliance test
- Test all 5 specialists
- Score each response
- Document compliance

**Day 2-3**: Protocol violation tests
- Test violation detection
- Test recovery protocols

**Day 4-5**: Complex scenarios
- Multi-specialist collaboration
- Error recovery validation

### Phase 3: Analysis & Sprint 2 Prep (Week 3)

**Day 1-2**: Data analysis
- Calculate all 4 primary metrics
- Generate compliance reports
- Compare against targets

**Day 3-4**: Documentation
- Update progress.md with findings
- Create Sprint 1 summary report
- Document lessons learned

**Day 5**: Sprint 2 prep
- Review metrics vs. targets
- Identify improvement opportunities
- Plan Sprint 2 test expansions

---

## Evidence Collection Standards

**Required Evidence per Test**:

1. **Pre-execution state**: Directory listing before test
2. **Specialist responses**: Screenshots and structured output
3. **Coordinator actions**: Verification command outputs
4. **Post-execution state**: Directory listing after test
5. **Success/failure documentation**: Test execution report

**Evidence Repository Structure**:
```
test-workspace/
├── evidence/
│   ├── test-1.1/
│   │   ├── iteration-1/
│   │   │   ├── pre-state.txt
│   │   │   ├── specialist-response.png
│   │   │   ├── coordinator-actions.png
│   │   │   ├── post-state.txt
│   │   │   └── report.md
│   │   ├── iteration-2/
│   │   └── iteration-3/
│   └── test-2.1/
└── summary-reports/
    ├── sprint-1-baseline.md
    ├── compliance-report.md
    └── metrics-summary.md
```

---

## Quick Reference

### Essential Commands

```bash
# Clean test workspace
rm -rf test-workspace/* && ls -la test-workspace/

# Verify file creation
ls -lh [file-path]

# Verify content
cat [file-path] | head -n 10

# Find all test files
find test-workspace -type f -name "test-*"

# Check verification timestamps
grep "✅.*verified:" progress.md | tail -n 5

# Count files created today
find test-workspace -type f -mtime -1 | wc -l
```

### Success Criteria Checklist

For ANY test execution:
- [ ] Specialist provides structured output (no Write attempts)
- [ ] Coordinator executes pre-verification (ls before Write)
- [ ] Coordinator executes Write tool
- [ ] Coordinator executes post-verification (ls + content)
- [ ] File(s) persist on filesystem
- [ ] Verification timestamp documented in progress.md
- [ ] Task marked [x] only after verification
- [ ] Evidence collected and archived

### Metric Targets Summary

| Metric | Target |
|--------|--------|
| Coordinator protocol compliance | >95% |
| File persistence rate | >80% |
| Specialist compliance | 100% |
| Protocol violations | <5 per 100 tasks |
| Multi-file persistence | >60% |
| Nested directory persistence | >65% |
| Edit operation success | >75% |

---

## Sprint 2 Comparison Framework

**Purpose**: Measure improvement from Sprint 1 (protocol enforcement) to Sprint 2 (coordinator-as-executor)

### Comparison Metrics

| Metric | Sprint 1 Baseline | Sprint 1 Target | Sprint 2 Target |
|--------|-------------------|-----------------|-----------------|
| File persistence rate | ~30% | >80% | >95% |
| Multi-file persistence | ~10% | >60% | >90% |
| Nested dir persistence | ~20% | >65% | >90% |
| Protocol compliance | N/A | >95% | >98% |
| Specialist compliance | ~50% | 100% | 100% |
| Violation rate | ~20/100 | <5/100 | <2/100 |

---

**End of Regression Test Suite**