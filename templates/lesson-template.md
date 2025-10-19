# [Lesson Title - Concise, Descriptive]

**Lesson ID**: L-[CATEGORY]-[NUMBER]
**Category**: [Technical | Process | Architectural | Security | Performance | Communication]
**Severity**: [Critical | High | Medium | Low]
**Discovered**: [YYYY-MM-DD]
**Mission**: [mission-name where this was discovered]
**Related Issues**: [#issue-1, #issue-2 from progress.md]
**Related Missions**: [mission-1, mission-2 where also encountered]

---

## 🔍 Problem

### What Was the Challenge?

[Clear, concise description of the problem or issue encountered. Focus on the observable symptoms and business impact.]

**Symptom**:
[What was the observable problem that indicated something was wrong? Be specific.]

**Context**:
[When/where/how does this problem occur? What conditions trigger it?]

**Impact**:
[What were the consequences? How did this affect users, system, or development?]

**Business Cost**:
- [Time lost: X hours]
- [Affected users: Y]
- [Service downtime: Z minutes]
- [Development velocity impact: description]

---

## 🔬 Root Cause

### Why Did This Happen?

[Deep analysis of the underlying reason for the problem. Don't stop at surface symptoms - explain WHY it occurred at a fundamental level.]

**Root Cause Analysis**:
[The fundamental reason this issue existed. Not just "what was wrong" but "why was it designed this way" or "why did we miss this".]

**Contributing Factors**:
1. [Factor 1 that contributed to the issue]
2. [Factor 2 that made the issue worse or harder to detect]
3. [Factor 3 - architectural, process, or knowledge gaps]

**Why It Wasn't Caught Earlier**:
- [Reason 1: gap in testing, monitoring, code review, etc.]
- [Reason 2: assumptions made that were incorrect]
- [Reason 3: knowledge gap or blind spot]

**Pattern Recognition**:
[Is this part of a larger pattern? Similar to other issues? Category of problem?]

---

## ✅ Solution

### How Was This Resolved?

[Detailed explanation of how the problem was solved. Include the thought process, not just the final implementation.]

**Approach**:
[The strategy or methodology used to solve the problem. Why this approach over alternatives?]

**Implementation Steps**:
1. [Step 1 with specific technical details]
2. [Step 2 with code snippets or configuration if applicable]
3. [Step 3 with verification method]

**Code Example** (if applicable):
```[language]
# Before (problematic code)
[problematic code snippet]

# After (solution)
[fixed code snippet with comments explaining key changes]
```

**Configuration Changes** (if applicable):
```[format]
# Before
[old configuration]

# After
[new configuration]
```

**Results After Implementation**:
- [Metric 1: improvement observed]
- [Metric 2: problem eliminated]
- [Metric 3: side effects or trade-offs]

**Verification Method**:
[How to verify the solution works correctly. Tests added, monitoring checks, etc.]

**Trade-offs Accepted**:
- [Trade-off 1: what was sacrificed for this solution]
- [Trade-off 2: limitations or constraints introduced]

---

## 🛡️ Prevention

### How to Avoid This in the Future

[Specific, actionable steps to prevent this issue from recurring. Focus on process, architecture, and automation.]

**Detection Strategy**:
[How to identify this issue early if it occurs again]

**Early Warning Signs**:
- [Sign 1 that this issue is starting to develop]
- [Sign 2 in logs, metrics, or behavior]
- [Sign 3 in code patterns or architecture]

**Prevention Steps**:
1. [Step 1: Architectural change to prevent recurrence]
   - Why: [Rationale]
   - How: [Implementation approach]
   - Example: [Concrete example]

2. [Step 2: Process improvement needed]
   - Why: [Rationale]
   - How: [Implementation approach]
   - Example: [Concrete example]

3. [Step 3: Monitoring or automation to catch early]
   - Why: [Rationale]
   - How: [Implementation approach]
   - Example: [Concrete example]

**Architectural Changes Needed**:
- [Change 1: Design pattern or structure improvement]
- [Change 2: Technology or tool adoption]

**Process Changes Needed**:
- [Change 1: Code review checklist item]
- [Change 2: Testing requirement]
- [Change 3: Documentation standard]

**Monitoring & Alerts**:
- [Metric to monitor with threshold]
- [Alert condition to set up]
- [Dashboard or log to review]

**Testing Strategy**:
- [Test type needed to catch this issue]
- [Test case examples]
- [Coverage requirement]

---

## 🎯 Application

### When and Where to Apply This Lesson

[Specific guidance on when this lesson applies and when it doesn't. Help future developers recognize similar situations.]

**Applies To**:
- [Project type 1: e.g., microservices architectures]
- [Project type 2: e.g., projects with authentication]
- [Scenario 1: e.g., serverless deployments]
- [Scenario 2: e.g., high-traffic APIs]

**Does NOT Apply To**:
- [Exception 1: when this lesson is not relevant]
- [Exception 2: scenarios where different approach needed]
- [Exception 3: edge cases to be aware of]

**Recognition Criteria**:
[How to recognize when this lesson is relevant to current work]
- If you see: [Pattern or symptom]
- If you're building: [Type of feature or system]
- If you're using: [Technology or tool]

**Application Examples**:

### Example 1: [Scenario Name]
**Context**: [Specific situation where this applies]
**How to Apply**: [Step-by-step application of lesson]
**Expected Outcome**: [What happens when applied correctly]

### Example 2: [Scenario Name]
**Context**: [Different situation]
**How to Apply**: [Adaptation of lesson to this context]
**Expected Outcome**: [Results]

**Anti-Patterns to Avoid**:
- ❌ [Incorrect application 1]
- ❌ [Incorrect application 2]
- ❌ [Over-applying this lesson where not needed]

---

## 📊 Evidence

### Supporting Materials

**Issue Reference**: [#issue-id in progress.md with full fix attempts history]

**Mission References**:
- [mission-name-1]: First encountered, initial solution
- [mission-name-2]: Refined approach
- [mission-name-3]: Validated pattern

**Code References**:
- [file:line-range where fix implemented]
- [file:line-range where pattern now used]

**Documentation**:
- [Link to PR or commit]
- [Link to architectural decision record]
- [Link to external documentation]

**Metrics & Impact**:
- Before: [Metric value before fix]
- After: [Metric value after fix]
- Improvement: [% or absolute improvement]

**Screenshots/Diagrams** (if applicable):
- [Path to screenshot or diagram in evidence-repository]
- [Description of what it shows]

---

## 🔗 Related Lessons

### Connected Learnings

- **[L-CATEGORY-NUMBER]**: [Related lesson title]
  - **Relationship**: [How this relates - prerequisite, alternative, complementary]
  - **Why Review**: [When to review this related lesson together]

- **[L-CATEGORY-NUMBER]**: [Related lesson title]
  - **Relationship**: [Connection type]
  - **Why Review**: [Reason]

### Pattern Family

This lesson is part of the **[Pattern Family Name]** family:
- [Related pattern 1]
- [Related pattern 2]
- [Related pattern 3]

### Prerequisite Knowledge

To understand this lesson, familiarity with these concepts helps:
- [Concept 1]
- [Concept 2]
- [Concept 3]

---

## 🏷️ Keywords

`[keyword1]`, `[keyword2]`, `[keyword3]`, `[keyword4]`, `[keyword5]`, `[keyword6]`, `[keyword7]`, `[keyword8]`

**Primary Keywords** (main concepts):
- `[main-keyword-1]`
- `[main-keyword-2]`

**Secondary Keywords** (related concepts):
- `[related-keyword-1]`
- `[related-keyword-2]`

**Technology Keywords**:
- `[tech-1]`
- `[tech-2]`

**Search Optimization**:
Common search terms someone might use to find this lesson:
- "[search phrase 1]"
- "[search phrase 2]"
- "[search phrase 3]"

---

## 📚 References

### External Resources

**Official Documentation**:
- [Tool/Framework Name]: [URL to relevant docs]
- [Technology Name]: [URL to best practices guide]

**Community Resources**:
- [Blog post or article]: [URL with key takeaway]
- [Stack Overflow discussion]: [URL with relevant answer]
- [GitHub issue or PR]: [URL with context]

**Books/Papers**:
- [Book title]: [Chapter/section relevant to this lesson]
- [Research paper]: [Key finding applicable here]

**Internal Documentation**:
- `progress.md`: [Issue #X] - Original problem discovery
- `architecture.md`: [Section] - Architectural decision context
- `archives/missions/[mission-name]/`: Historical context

---

## 📈 Application History

### Times Applied: [X]

#### Application 1: [Mission Name] - [YYYY-MM-DD]
**Context**: [What was being built]
**How Applied**: [Specific implementation]
**Outcome**: [Result - success or learned refinement]
**Refinement**: [What was learned or adjusted]

#### Application 2: [Mission Name] - [YYYY-MM-DD]
**Context**: [Different context]
**How Applied**: [Implementation variation]
**Outcome**: [Result]
**Refinement**: [Adjustments made]

#### Application 3: [Mission Name] - [YYYY-MM-DD]
**Context**: [Another context]
**How Applied**: [Implementation approach]
**Outcome**: [Result]
**Refinement**: [Learning]

**Success Rate**: [X/Y applications successful]
**Average Time Saved**: [X hours per application]
**Common Variations**: [How application differs across contexts]

---

## 🔄 Lesson Evolution

### Version History

**v1.0** - [YYYY-MM-DD] - Initial lesson creation
- Discovered in [mission-name]
- Initial solution documented

**v1.1** - [YYYY-MM-DD] - Updated with additional context
- Applied in [mission-name], refined approach
- Added prevention steps

**v1.2** - [YYYY-MM-DD] - Expanded with edge cases
- Encountered edge case in [mission-name]
- Added "Does NOT Apply To" section

**Current Version**: v1.X - [YYYY-MM-DD]

### Future Improvements Needed

- [ ] [Improvement 1: additional testing strategy]
- [ ] [Improvement 2: better automation]
- [ ] [Improvement 3: more examples]

### Review Schedule

- **Next Review**: [YYYY-MM-DD]
- **Review Frequency**: [Every X months or after Y applications]
- **Review Criteria**: [What triggers a review - e.g., new application, failure, technology change]

---

## 📝 Notes

### Additional Context

[Any additional notes, caveats, or context that doesn't fit in other sections but is important to capture]

### Known Limitations

- [Limitation 1: where this solution doesn't work well]
- [Limitation 2: constraints or prerequisites]

### Future Considerations

- [Consideration 1: emerging technology that might change this]
- [Consideration 2: architectural trends to watch]

### Team Feedback

> "[Quote from team member about this lesson]" - @specialist-name

> "[Another perspective or learning]" - @specialist-name

---

## ✍️ Metadata

**Created By**: @[agent-name]
**Created Date**: [YYYY-MM-DD]
**Last Updated By**: @[agent-name]
**Last Updated Date**: [YYYY-MM-DD]
**Lesson Status**: [Draft | Active | Validated | Archived]
**Validation**: [Validated across X missions | Needs more validation]

**Indexed In**: `lessons/index.md`
**File Path**: `lessons/[category]/[this-file].md`

---

## Template Usage Notes

**Remove this section when creating actual lesson**

### How to Use This Template

1. **Copy template**: `cp templates/lesson-template.md lessons/[category]/[short-name].md`
2. **Fill all sections**: Replace all `[bracketed text]` with actual content
3. **Assign Lesson ID**: Follow format `L-[CATEGORY]-[NUMBER]`
4. **Set severity**: Choose Critical, High, Medium, or Low based on impact
5. **Add keywords**: Minimum 5, include technical terms and search terms
6. **Link related**: Reference issues in progress.md and related lessons
7. **Update index**: Add to `lessons/index.md` in appropriate sections

### Section Guidelines

**Problem**: Focus on observable symptoms and business impact
**Root Cause**: Go deep - explain WHY, not just what
**Solution**: Include code examples and step-by-step implementation
**Prevention**: Be specific and actionable
**Application**: Help readers recognize when to use this
**Keywords**: Include terms people would search for
**Evidence**: Link to source materials and proof

### Quality Checklist

Before marking lesson complete:
- [ ] All sections filled with specific, actionable content
- [ ] Code examples included (if applicable)
- [ ] Keywords added (minimum 5)
- [ ] Related lessons linked
- [ ] Lesson ID unique and follows format
- [ ] Added to lessons/index.md
- [ ] Severity assigned based on impact
- [ ] Application examples concrete and realistic
- [ ] Prevention steps specific and testable

---

**This is a template. Remove all instructional text when creating actual lessons.**
