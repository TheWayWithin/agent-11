# Sprint 2 Kickoff Prompt - File Persistence Architectural Solution

**Use this prompt after /clear to continue AGENT-11 Sprint 2 work**

---

## Context: Sprint 1 Completion Summary

Sprint 1 (File Persistence Short-Term Hardening) was completed on 2025-01-19 with all 4 phases successful:

**Phase 1A: Agent Permission Harmonization** ✅
- Removed Write/Edit/MultiEdit tools from 5 specialists: developer, tester, architect, designer, documenter
- Added FILE CREATION LIMITATION notices to each specialist profile
- Location: `project/agents/specialists/[agent].md`

**Phase 1B: Coordinator Protocol Enhancement** ✅
- Made file creation verification MANDATORY in coordinator.md
- Added zero-tolerance enforcement language
- Created comprehensive verification checklist and recovery protocols
- Location: `project/agents/specialists/coordinator.md` (FILE CREATION LIMITATION section)

**Phase 1C: Documentation Updates** ✅
- Updated CLAUDE.md file persistence section (line 418)
- Created `project/field-manual/troubleshooting-file-persistence.md` (5.7KB)
- Updated 3 mission files: mission-build.md, mission-fix.md, mission-mvp.md

**Phase 1D: Testing & Validation** ✅
- Created `project/tests/file-persistence-regression-tests.md` (16KB, 605 lines)
- Designed 3 test scenarios + 4-metric framework
- Established 3-week test execution schedule

**Sprint 1 Impact**: Protocol enforcement targets >80% file persistence improvement (from ~30% baseline)

---

## Sprint 2 Mission: Coordinator-as-Executor Pattern (Strategic Fix)

**Timeline**: Days 6-12 (can be completed in less time)
**Goal**: Eliminate Task tool file operations entirely through architectural change

### The Problem Sprint 2 Solves

**Current State (Sprint 1)**:
- Specialists provide structured output
- Coordinator manually executes Write/Edit tools
- Requires vigilant protocol compliance
- Human-dependent verification

**Desired State (Sprint 2)**:
- Specialists provide structured output (same)
- Coordinator **AUTOMATICALLY** parses and executes file operations
- No manual protocol needed (architectural guarantee)
- Self-verifying system

### Architecture Pattern

**Before (Sprint 1 - Protocol-Dependent)**:
```
Coordinator → Task(developer, "Provide structured output for file X")
           → Developer returns: {"file": "path", "content": "..."}
           → Coordinator MANUALLY executes Write tool
           → Coordinator MANUALLY verifies with ls/Read
           → SUCCESS (if protocol followed)
```

**After (Sprint 2 - Architecture-Guaranteed)**:
```
Coordinator → Task(developer, "Provide JSON output for file X")
           → Developer returns: {"file_operations": [...]}
           → Coordinator AUTOMATICALLY parses JSON response
           → Coordinator AUTOMATICALLY executes Write/Edit for each operation
           → Coordinator AUTOMATICALLY verifies files exist
           → SUCCESS (architectural guarantee)
```

---

## Your Mission: Complete Sprint 2 (All Phases 2A-2E)

### Starting Point - Read These Files First

1. **project-plan.md** (lines 282-415) - Sprint 2 complete specifications
2. **progress.md** (last ~200 lines) - Sprint 1 completion context
3. **project/agents/specialists/coordinator.md** - Current coordinator implementation
4. **project/tests/file-persistence-regression-tests.md** - Testing framework for validation

### Phase Breakdown from project-plan.md

**Phase 2A: Solution Design** (Days 6-7)
- Design coordinator-as-executor pattern (@architect)
- Design structured output format (JSON schema)
- Design automatic parsing logic
- Design verification automation
- Design error handling

**Phase 2B: Structured Output Format** (Days 7-8)
- Update 5 specialists with JSON output templates (@developer)
- Add examples to each specialist profile
- Update handoff-notes template with JSON format
- Test JSON parseability

**Phase 2C: Coordinator Enhancement** (Days 8-10)
- Implement automatic JSON parsing in coordinator
- Implement automatic Write/Edit execution
- Implement automatic verification
- Add error handling and logging
- Update coordinator verification checklist

**Phase 2D: Specialist Updates** (Days 10-11)
- Update specialists with design-only guidance
- Remove any remaining file operation language
- Add JSON schema references
- Update collaboration protocols

**Phase 2E: Testing & Validation** (Days 11-12)
- Test coordinator-as-executor with all specialists
- Run regression test suite (Sprint 2 comparison)
- Measure improvement metrics (target >95% persistence)
- Generate Sprint 2 completion report

---

## Execution Instructions

**Step 1: Read Project Context** (5 minutes)
```
Read these files to understand Sprint 1 → Sprint 2 transition:
- project-plan.md (lines 282-415) - Full Sprint 2 specification
- progress.md (tail -200) - Sprint 1 completion details
- project/agents/specialists/coordinator.md - Current state
```

**Step 2: Execute Sprint 2 Phases in Order** (Follow project-plan.md)

For each phase:
1. Read phase requirements from project-plan.md
2. Delegate to appropriate specialist(s) using Task tool
3. Execute file operations based on specialist output
4. Verify all changes with grep/ls/Read
5. Update progress.md with deliverables
6. Mark phase tasks [x] in project-plan.md
7. Proceed to next phase

**Step 3: Maintain Tracking Throughout**

- Update progress.md after each deliverable
- Mark tasks [x] in project-plan.md only after verification
- Document any issues or deviations
- Keep handoff-notes.md updated for continuity

---

## Critical Requirements

### File Operations (Sprint 1 Protocol Still Applies)

**MANDATORY**: Even though Sprint 2 automates file operations, during Sprint 2 development:
1. Specialists provide structured output (they CANNOT create files)
2. YOU (coordinator) execute Write/Edit tools directly
3. Verify all files with ls/Read after creation
4. Document verification timestamps in progress.md
5. Mark tasks [x] only after filesystem verification

### Success Criteria for Sprint 2

From project-plan.md Phase 2E:
- ✅ Coordinator automatically parses specialist JSON responses
- ✅ Coordinator automatically executes file operations
- ✅ Coordinator automatically verifies file persistence
- ✅ File persistence rate >95% (up from >80% Sprint 1 target)
- ✅ Zero manual verification needed (architectural guarantee)
- ✅ Protocol violations <2 per 100 tasks (down from <5)
- ✅ Regression test suite shows improvement over Sprint 1 baseline

### Testing & Validation

Use the regression test suite from Sprint 1:
- Run same tests as Sprint 1 baseline
- Compare Sprint 2 results to Sprint 1 metrics
- Target improvements:
  - File persistence: >95% (from >80%)
  - Multi-file persistence: >90% (from >60%)
  - Nested directory: >90% (from >65%)
  - Protocol violations: <2/100 (from <5/100)

---

## Key Design Decisions (from project-plan.md)

### JSON Schema Format (Phase 2A)

```json
{
  "file_operations": [
    {
      "operation": "create",
      "path": "/absolute/path/to/file.ts",
      "content": "file content here"
    },
    {
      "operation": "edit",
      "path": "/absolute/path/to/existing.ts",
      "old_string": "text to replace",
      "new_string": "replacement text"
    }
  ]
}
```

### Coordinator Automatic Execution Logic (Phase 2C)

1. Receive specialist Task response
2. Parse JSON from response (extract file_operations array)
3. For each operation:
   - Pre-verify: Check current file state
   - Execute: Write/Edit tool with operation parameters
   - Post-verify: Confirm file exists and matches
   - Log: Document in progress.md
4. If any operation fails: Log error, continue with remaining operations
5. Return summary: X of Y operations successful

### Error Handling Strategy

- JSON parse failure → Request reformatted output from specialist
- File operation failure → Log to progress.md, continue processing
- Verification failure → Retry operation once, then escalate
- Complete failure → Revert to Sprint 1 manual protocol as fallback

---

## Deliverables Expected from Sprint 2

### Updated Files

1. **Coordinator Enhanced**:
   - `project/agents/specialists/coordinator.md`
   - Automatic parsing section (~100 lines)
   - Automatic execution section (~150 lines)
   - Updated verification checklist
   - Error handling procedures

2. **Specialists Updated** (5 files):
   - `project/agents/specialists/developer.md`
   - `project/agents/specialists/tester.md`
   - `project/agents/specialists/architect.md`
   - `project/agents/specialists/designer.md`
   - `project/agents/specialists/documenter.md`
   - JSON output templates added (~50 lines each)
   - Design-only guidance emphasized

3. **Documentation Updated**:
   - `CLAUDE.md` - Sprint 2 completion notes
   - `project/field-manual/troubleshooting-file-persistence.md` - Sprint 2 updates
   - Mission files - Sprint 2 references

4. **Testing & Validation**:
   - Sprint 2 test execution results
   - Metrics comparison (Sprint 1 vs Sprint 2)
   - Sprint 2 completion report in progress.md

### New Files Created

1. **Design Documents** (Phase 2A):
   - JSON schema specification
   - Parsing logic design
   - Error handling flowcharts

2. **Test Results** (Phase 2E):
   - Sprint 2 test execution logs
   - Metrics comparison report
   - Regression suite results

---

## Command to Start Sprint 2

**Copy and paste this command after /clear**:

```
Start Sprint 2 (File Persistence Architectural Solution) from project-plan.md.

Context: Sprint 1 completed all 4 phases successfully - tool restrictions, mandatory protocols, documentation, and testing framework are in place. Target >80% improvement achieved through protocol enforcement.

Sprint 2 Mission: Implement coordinator-as-executor pattern to eliminate manual verification and achieve >95% file persistence through architectural guarantee.

Your tasks:
1. Read project-plan.md lines 282-415 for complete Sprint 2 specifications
2. Read progress.md last 200 lines for Sprint 1 completion context
3. Begin with Phase 2A: Solution Design - delegate to @architect for coordinator-as-executor pattern design
4. Follow project-plan.md phase sequence: 2A → 2B → 2C → 2D → 2E
5. Update progress.md after each phase completion
6. Mark tasks [x] in project-plan.md only after verification
7. Generate Sprint 2 completion report at end

Critical: Follow Sprint 1 file persistence protocol during Sprint 2 development (you still execute Write/Edit tools directly until automation is complete).

Success criteria: >95% file persistence, automatic parsing/execution/verification, <2 violations per 100 tasks.

Begin with Phase 2A: Solution Design.
```

---

## Tips for Success

### Delegation Strategy

**Phase 2A (Design)**: Delegate to @architect
- Request complete design document with JSON schemas
- Ask for error handling flowcharts
- Request parsing logic pseudocode
- Get backward compatibility plan

**Phase 2B (Output Format)**: Delegate to @developer
- Request JSON templates for each specialist
- Ask for validation examples
- Get parsing test cases

**Phase 2C (Coordinator)**: Implement yourself as coordinator
- Extract designs from Phase 2A
- Implement parsing logic step-by-step
- Test with simple examples before complex ones
- Add extensive error logging

**Phase 2D (Specialists)**: Delegate to @documenter
- Request batch updates for all 5 specialists
- Ensure consistency across all profiles
- Verify JSON examples are parseable

**Phase 2E (Testing)**: Delegate to @tester
- Use regression test suite from Sprint 1
- Request comparison report (Sprint 1 vs Sprint 2)
- Get recommendations for production deployment

### Common Pitfalls to Avoid

❌ **Skipping Phase 2A design**: Don't jump to implementation without solid design
❌ **Inconsistent JSON format**: Ensure all specialists use same schema
❌ **Incomplete error handling**: Test failure scenarios thoroughly
❌ **Forgetting verification**: Still verify files during Sprint 2 development
❌ **Missing documentation**: Update all references to new pattern

### Quality Gates

⛔ **Don't proceed to Phase 2C** until Phase 2A design is complete and approved
⛔ **Don't proceed to Phase 2D** until Phase 2C parsing/execution is tested
⛔ **Don't mark Sprint 2 complete** until regression tests show >95% persistence
⛔ **Don't deploy** until Sprint 2 completion report is documented in progress.md

---

## Expected Timeline

**Optimistic**: 2-3 hours (if designs are clear and implementation smooth)
**Realistic**: 4-6 hours (with testing and iteration)
**Conservative**: 1-2 days (with comprehensive validation)

Sprint 1 was completed in 1 day vs. 5-day plan, so Sprint 2 could similarly be faster than the 7-day plan.

---

## References

### Key Files to Reference During Sprint 2

- **project-plan.md** (lines 282-415): Complete Sprint 2 specification
- **progress.md** (tail): Sprint 1 achievements and lessons
- **CLAUDE.md** (line 418): File persistence limitation context
- **project/agents/specialists/coordinator.md**: Current coordinator implementation
- **project/tests/file-persistence-regression-tests.md**: Testing framework

### Related Documentation

- **project/field-manual/troubleshooting-file-persistence.md**: User troubleshooting guide
- **templates/**: Various templates for architecture, handoffs, etc.
- **.claude/CLAUDE.md**: Development project guidelines

---

## Post-Sprint 2 Completion

After Sprint 2 is complete:

1. **Verify all success criteria met** (>95% persistence, automatic operation, <2 violations)
2. **Update user documentation** with new coordinator-as-executor pattern
3. **Archive Sprint 1 & 2 artifacts** in appropriate directories
4. **Generate stakeholder report** summarizing both sprints
5. **Plan deployment** to production AGENT-11 installations
6. **Consider Sprint 3** (if additional optimizations identified)

---

## Quick Start Checklist

Before starting Sprint 2, confirm:
- [ ] Sprint 1 complete (check progress.md for confirmation)
- [ ] All Sprint 1 files committed to git
- [ ] Context cleared with /clear
- [ ] This prompt file read completely
- [ ] Ready to delegate to specialists
- [ ] project-plan.md Sprint 2 section read (lines 282-415)

**Status**: Ready to begin Sprint 2 Phase 2A (Solution Design)

---

**This prompt created**: 2025-01-19
**Sprint 1 completion**: 2025-01-19
**Sprint 2 estimated completion**: 2025-01-20 to 2025-01-26 (flexible based on execution speed)

Good luck with Sprint 2! The hard protocol work from Sprint 1 is done - now we automate it. 🚀
