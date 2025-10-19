# Project Plan

**Mission**: [Mission Name]
**Commander**: @coordinator
**Started**: [YYYY-MM-DD]
**Status**: [🟢 Active | 🟡 Paused | 🟠 At Risk | 🔴 Blocked | ✅ Complete]
**Last Updated**: [YYYY-MM-DD HH:MM]

---

## 📋 Executive Summary

**Mission Objective**:
[Clear, concise statement of what this mission aims to achieve - 1-2 sentences]

**Success Criteria**:
- [ ] [Measurable outcome 1]
- [ ] [Measurable outcome 2]
- [ ] [Measurable outcome 3]

**Current Status**:
[Brief summary of where we are now - completed phases, current phase, blockers]

---

## 🎯 Mission Objectives

### Primary Objectives (Must Have)
1. [Core objective 1 with success metric]
2. [Core objective 2 with success metric]
3. [Core objective 3 with success metric]

### Secondary Objectives (Should Have)
1. [Enhanced objective 1]
2. [Enhanced objective 2]

### Stretch Goals (Nice to Have)
1. [Aspirational goal 1]
2. [Aspirational goal 2]

---

## 🏗️ Technical Architecture

**Tech Stack**:
- **Frontend**: [Framework/library with version]
- **Backend**: [Framework/platform with version]
- **Database**: [Database with version]
- **Infrastructure**: [Hosting/deployment platform]
- **Key Dependencies**: [Critical libraries]

**Architecture Decisions**:
- [Key decision 1 with rationale]
- [Key decision 2 with rationale]

**Integration Points**:
- [External service 1: purpose]
- [External service 2: purpose]

**Reference**: See `architecture.md` for detailed technical design

---

## 📅 Milestone Timeline

### Milestone 1: [Phase Name] - [Target Date]
**Objective**: [What this milestone achieves]
**Status**: [🟢 On Track | 🟡 At Risk | 🔴 Delayed | ✅ Complete]

**Key Deliverables**:
- [ ] [Deliverable 1]
- [ ] [Deliverable 2]
- [ ] [Deliverable 3]

### Milestone 2: [Phase Name] - [Target Date]
**Objective**: [What this milestone achieves]
**Status**: [🟢 On Track | 🟡 At Risk | 🔴 Delayed | ✅ Complete]

**Key Deliverables**:
- [ ] [Deliverable 1]
- [ ] [Deliverable 2]

### Milestone 3: [Phase Name] - [Target Date]
**Objective**: [What this milestone achieves]
**Status**: [🟢 On Track | 🟡 At Risk | 🔴 Delayed | ✅ Complete]

**Key Deliverables**:
- [ ] [Deliverable 1]
- [ ] [Deliverable 2]

---

## ✅ Task Breakdown

### TASK COMPLETION VERIFICATION PROTOCOL

**CRITICAL RULES** (Mandatory for all task updates):

1. **ONLY mark [x] after specialist CONFIRMATION**
   - Receive actual Task tool response with deliverables
   - Verify specialist updated handoff-notes.md with findings
   - Confirm deliverable exists and meets requirements
   - ❌ NEVER mark [x] based on assumption or plan
   - ❌ NEVER mark [x] before specialist completes work

2. **VERIFICATION CHECKLIST** (Before marking ANY task [x]):
   - [ ] Task tool returned actual response (not timeout/error)
   - [ ] Specialist provided specific deliverables or status
   - [ ] Specialist updated handoff-notes.md
   - [ ] Deliverable files exist at specified paths
   - [ ] Quality spot-check passed (code runs, docs readable, tests pass)
   - [ ] No blockers preventing next dependent task

3. **CROSS-FILE SYNCHRONIZATION** (Mandatory after task [x]):
   - Update progress.md with deliverable entry
   - Merge specialist findings into agent-context.md
   - Verify handoff-notes.md ready for next specialist
   - Update milestone status if phase complete

4. **TODO LIST INTEGRATION**:
   - TodoWrite derives tasks FROM this file (not independent)
   - TodoWrite marks in_progress when specialist starts
   - TodoWrite marks completed ONLY when [x] verified here
   - Sync TodoWrite → project-plan.md immediately

**Example of CORRECT Task Tracking**:
```markdown
### Phase 1: Requirements
- [x] Define user stories (@strategist) - ✅ 2025-10-19 14:30
  - Deliverable: user-stories.md with 15 stories
  - Verified: File exists, handoff-notes.md updated
  - Next: @architect reviews for technical feasibility

- [ ] Review technical feasibility (@architect) - 🟡 In Progress
  - Started: 2025-10-19 15:00
  - Waiting for: @architect Task tool response
  - Status: Delegated via Task tool, awaiting completion
```

**Example of INCORRECT Task Tracking** (DO NOT DO THIS):
```markdown
### Phase 1: Requirements
- [x] Define user stories (@strategist)
  - Status: Delegated to strategist
  - Next: Architecture review
```
*(Problems: No verification, no deliverable confirmation, no timestamp, marked [x] without specialist confirmation)*

---

### Phase 1: [Phase Name] - [Status: 🟢 Not Started | 🔵 In Progress | ✅ Complete]

**Phase Objective**: [Clear statement of what this phase achieves]

**Dependencies**: [What must be complete before this phase starts]

**Tasks**:
- [ ] [Task 1 description] (@[specialist-name])
  - **Requirements**: [Specific requirements for task]
  - **Deliverables**: [Expected outputs with file paths]
  - **Acceptance Criteria**: [How to verify completion]
  - **Status**: [Not Started | In Progress | Blocked | Complete]

- [ ] [Task 2 description] (@[specialist-name])
  - **Requirements**: [Specific requirements]
  - **Deliverables**: [Expected outputs]
  - **Acceptance Criteria**: [Verification criteria]
  - **Dependencies**: [Task 1 must complete first]

- [ ] [Task 3 description] (@[specialist-name])
  - **Requirements**: [Specific requirements]
  - **Deliverables**: [Expected outputs]
  - **Acceptance Criteria**: [Verification criteria]
  - **Parallel OK**: Can run with Task 2

**Phase Exit Criteria**:
- [ ] All tasks verified complete (not just marked [x])
- [ ] All deliverables exist and meet quality standards
- [ ] progress.md updated with phase lessons
- [ ] agent-context.md updated with phase findings
- [ ] handoff-notes.md prepared for next phase
- [ ] No critical blockers remaining

---

### Phase 2: [Phase Name] - [Status]

**Phase Objective**: [What this phase achieves]

**Dependencies**: [Phase 1 must be complete]

**Tasks**:
- [ ] [Task 1] (@[specialist])
  - **Requirements**: [Details]
  - **Deliverables**: [Outputs]
  - **Acceptance Criteria**: [Verification]

- [ ] [Task 2] (@[specialist])
  - **Requirements**: [Details]
  - **Deliverables**: [Outputs]
  - **Acceptance Criteria**: [Verification]

**Phase Exit Criteria**:
- [ ] All tasks verified complete
- [ ] All context files updated
- [ ] Ready for Phase 3

---

### Phase 3: [Phase Name] - [Status]

**Phase Objective**: [What this phase achieves]

**Dependencies**: [Phase 2 must be complete]

**Tasks**:
- [ ] [Task 1] (@[specialist])
- [ ] [Task 2] (@[specialist])
- [ ] [Task 3] (@[specialist])

**Phase Exit Criteria**:
- [ ] All verification steps complete
- [ ] Mission objectives achieved

---

## 📊 Success Metrics

### Key Performance Indicators

**Development Velocity**:
- **Target**: [X tasks per day/week]
- **Current**: [Actual rate]
- **Trend**: [Improving | Stable | Declining]

**Quality Metrics**:
- **First-Time Success Rate**: [Target: X%] [Actual: Y%]
- **Rework Rate**: [Target: <X%] [Actual: Y%]
- **Test Coverage**: [Target: X%] [Actual: Y%]

**Timeline Metrics**:
- **On-Time Delivery**: [X/Y milestones on schedule]
- **Schedule Variance**: [Days ahead/behind]

**Learning Metrics**:
- **Issues Resolved**: [X total]
- **Average Resolution Time**: [X hours]
- **Lessons Captured**: [X insights documented]

---

## 🚧 Risks & Mitigation

### Active Risks

#### Risk #1: [Risk Title]
**Probability**: [High | Medium | Low]
**Impact**: [High | Medium | Low]
**Status**: [🔴 Active | 🟡 Monitoring | 🟢 Mitigated]

**Description**:
[What could go wrong]

**Mitigation Strategy**:
- [Action 1 to reduce risk]
- [Action 2 to prepare for risk]

**Contingency Plan**:
[What to do if risk materializes]

#### Risk #2: [Risk Title]
**Probability**: [Level]
**Impact**: [Level]
**Status**: [Status]

**Description**: [Details]
**Mitigation**: [Strategy]
**Contingency**: [Backup plan]

---

## 🔗 Dependencies & Blockers

### External Dependencies
- **Dependency 1**: [What we're waiting for]
  - **Owner**: [Who/what provides it]
  - **Required By**: [Date/phase]
  - **Status**: [On Track | At Risk | Blocked]
  - **Impact if Delayed**: [Consequences]

- **Dependency 2**: [Details]
  - **Owner**: [Source]
  - **Required By**: [Date]
  - **Status**: [Status]

### Current Blockers
- **Blocker 1**: [Issue preventing progress]
  - **Discovered**: [Date]
  - **Affects**: [Which tasks/phases]
  - **Resolution Plan**: [How to unblock]
  - **ETA**: [Expected resolution date]

### Resolved Blockers (Reference)
- **[Date]** - [Blocker that was resolved]
  - **Resolution**: [How it was unblocked]
  - **Learning**: [What to avoid next time]

---

## 🎓 Lessons Learned (In-Flight)

### What's Working Well
- [Success 1 with reason why]
- [Success 2 with reason why]

### What Needs Improvement
- [Challenge 1 with proposed fix]
- [Challenge 2 with proposed fix]

### Key Insights
- [Insight 1 from this mission]
- [Insight 2 applicable to future work]

**Note**: Detailed lessons with root causes documented in `progress.md`

---

## 📦 Deliverables Status

### Completed Deliverables
- ✅ [Deliverable 1] - [Completion Date] - [Path or Location]
- ✅ [Deliverable 2] - [Completion Date] - [Path or Location]

### In Progress Deliverables
- 🔵 [Deliverable 3] - [Assigned to @specialist] - [Expected Date]
- 🔵 [Deliverable 4] - [Assigned to @specialist] - [Expected Date]

### Pending Deliverables
- ⏳ [Deliverable 5] - [Blocked by: Task X]
- ⏳ [Deliverable 6] - [Scheduled for Phase 3]

---

## 👥 Team & Responsibilities

### Specialist Assignments

**@coordinator** (Mission Commander):
- Overall mission orchestration
- Task delegation and verification
- Context preservation and handoffs
- Progress tracking and reporting

**@strategist** (Product Strategy):
- Requirements analysis: Phase 1
- User story definition: Phase 1
- Feature prioritization: Ongoing

**@architect** (Technical Design):
- Architecture design: Phase 1
- Technology decisions: Phase 1
- Technical reviews: Ongoing

**@developer** (Implementation):
- Feature development: Phase 2-3
- Bug fixes: Ongoing
- Code reviews: Ongoing

**@tester** (Quality Assurance):
- Test planning: Phase 1
- Test automation: Phase 2
- Quality validation: Phase 3

**@operator** (DevOps):
- Infrastructure setup: Phase 1
- CI/CD configuration: Phase 2
- Deployment: Phase 3

**@designer** (UI/UX):
- Design system: Phase 1
- UI implementation: Phase 2
- Design QA: Phase 3

---

## 📚 Documentation References

### Core Documentation
- **architecture.md** - Technical design and decisions
- **progress.md** - Chronological changelog and learnings
- **agent-context.md** - Mission-wide accumulated context
- **handoff-notes.md** - Current specialist context
- **evidence-repository.md** - Artifacts and supporting materials

### Supporting Documentation
- **ideation.md** - Original requirements and vision
- **CLAUDE.md** - Project configuration and principles
- **lessons/index.md** - Searchable lessons index (see next)

---

## 🔄 Update Protocol

### When to Update This File

**MANDATORY Updates** (Real-time):
1. **Mission Start**: Create with all Phase 1 tasks marked [ ]
2. **Phase Start**: Add all phase tasks BEFORE work begins
3. **Task Verification**: Mark [x] ONLY after specialist confirmation AND handoff verification
4. **Phase Complete**: Update phase status, add next phase tasks
5. **Blocker Discovered**: Add to Dependencies & Blockers immediately
6. **Risk Identified**: Add to Risks & Mitigation with strategy

**SYNCHRONIZED Updates** (Cross-file):
- When marking task [x] → Update progress.md with deliverable
- After specialist completion → Merge findings to agent-context.md
- After task [x] → Verify handoff-notes.md ready for next
- After phase → Extract lessons to progress.md

**Quality Checks** (Before updating):
- Verify specialist actually completed work (not just said they would)
- Confirm deliverable files exist at specified paths
- Check handoff-notes.md contains findings for next specialist
- Validate no broken dependencies before marking [x]

### Update Sequence (Mandatory Order)
1. Specialist completes work → Returns via Task tool
2. Coordinator verifies deliverable exists and meets criteria
3. Coordinator checks handoff-notes.md updated by specialist
4. Coordinator marks task [x] in project-plan.md with timestamp
5. Coordinator updates progress.md with deliverable entry
6. Coordinator merges findings into agent-context.md
7. Coordinator prepares handoff-notes.md for next specialist

### Common Update Mistakes to Avoid
- ❌ Marking [x] before specialist confirmation
- ❌ Updating only project-plan.md without progress.md sync
- ❌ Assuming completion without checking deliverable files
- ❌ Skipping handoff-notes.md verification
- ❌ Not timestamping completed tasks
- ❌ Forgetting to update milestone status after phase

---

## 📖 Template Usage Notes

**Remove this section when using template**

### How to Use This Template

1. **Initialize**: Copy to mission root, replace all `[bracketed]` placeholders
2. **Customize**: Adjust phases, tasks, milestones to match mission scope
3. **Maintain**: Update in real-time per Update Protocol above
4. **Verify**: Follow Task Completion Verification Protocol strictly
5. **Sync**: Keep cross-file references accurate (progress.md, agent-context.md)

### Template Principles

**Forward-Looking**: This file answers "What are we PLANNING to do?"
**Single Source of Truth**: Task completion status lives here only
**Verification-First**: Never mark [x] without confirmation
**Context-Aware**: Always maintain sync with handoff and context files
**Quality-Gated**: Phase exit criteria must be met before proceeding

### Integration with Other Files

- **project-plan.md** ← You are here (The Plan)
- **progress.md** → Chronological log of what was DONE
- **agent-context.md** → Rolling accumulation of findings
- **handoff-notes.md** → Next specialist's immediate context
- **lessons/index.md** → Searchable lessons reference

### Verification Examples

**GOOD Task Completion**:
```markdown
- [x] Implement authentication (@developer) - ✅ 2025-10-19 16:45
  - Deliverable: `src/auth/` with JWT implementation
  - Verified: Code exists, tests pass, handoff-notes.md updated
  - Performance: 50ms avg response time
  - Next: @tester for security validation
```

**BAD Task Completion**:
```markdown
- [x] Implement authentication (@developer)
  - Status: Complete
```
*(Missing: timestamp, deliverable verification, handoff check, next steps)*

---

**Mission Status**: This plan is a living document. Update immediately when status changes.

**Last Verification**: [YYYY-MM-DD HH:MM] by @coordinator
