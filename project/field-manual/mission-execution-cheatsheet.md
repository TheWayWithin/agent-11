# Mission Execution Cheatsheet

## 🚀 Before You Start

### Essential Pre-Mission Checklist
- [ ] **Choose the right mission** for your objective
- [ ] **Prepare input file** using templates (if required)
- [ ] **Review existing files** (project-plan.md, progress.md)
- [ ] **Set realistic expectations** based on mission duration
- [ ] **Clear workspace** of unrelated files

### Mission Selection Quick Guide
| Goal | Mission | Input File |
|------|---------|------------|
| Start new project | `dev-setup` | `ideation.md` |
| Understand existing code | `dev-alignment` | None |
| Build specific features | `build` | `requirements.md` |
| Create MVP | `mvp` | `vision.md` |
| Fix bugs | `fix` | `bug-report.md` |
| Design system | `architecture` | `vision.md` |

## 📋 Most Common Command Patterns

### New Project Setup
```bash
# Copy template and customize
cp templates/mission-inputs/ideation.md ./my-project-ideation.md
# Edit file with your project details
/coord dev-setup my-project-ideation.md
```

### Feature Development
```bash
# Copy template and fill requirements
cp templates/mission-inputs/requirements.md ./feature-requirements.md
# Edit with specific feature details
/coord build feature-requirements.md
```

### Bug Fixes
```bash
# Copy template and document bug
cp templates/mission-inputs/bug-report.md ./bug-report.md
# Fill with reproduction steps and details
/coord fix bug-report.md
```

### MVP Creation
```bash
# Copy template and define vision
cp templates/mission-inputs/vision.md ./mvp-vision.md
# Edit with product vision and goals
/coord mvp mvp-vision.md
```

## 📝 File Preparation Checklists

### For Requirements.md (BUILD mission)
- [ ] **Executive Summary**: Clear project description
- [ ] **User Stories**: Specific, testable acceptance criteria
- [ ] **Technical Requirements**: Performance, security, integration needs
- [ ] **Business Rules**: Logic constraints and validation rules
- [ ] **Success Metrics**: Measurable KPIs and goals
- [ ] **Quality Standards**: Testing and documentation requirements

### For Vision.md (MVP mission)
- [ ] **Problem Statement**: Specific pain point being solved
- [ ] **Target Users**: Detailed user personas
- [ ] **Core Features**: MVP scope (3-5 features max)
- [ ] **Business Model**: Revenue strategy and pricing
- [ ] **Success Metrics**: Launch and growth targets
- [ ] **Technical Approach**: Stack and architecture preferences

### For Bug-Report.md (FIX mission)
- [ ] **Priority Level**: P0 (critical) to P3 (low)
- [ ] **Reproduction Steps**: Exact steps to recreate issue
- [ ] **Environment Details**: Browser, OS, device specifics
- [ ] **Error Messages**: Complete stack traces and logs
- [ ] **Impact Assessment**: Users affected and business impact
- [ ] **Workarounds**: Temporary solutions if available

### For Ideation.md (DEV-SETUP mission)
- [ ] **Market Opportunity**: TAM, SAM, SOM analysis
- [ ] **Competitive Landscape**: Direct and indirect competitors
- [ ] **Technical Approach**: Preferred technology stack
- [ ] **Resource Requirements**: Team, budget, timeline
- [ ] **Risk Assessment**: Technical, market, financial risks
- [ ] **Success Metrics**: Launch and growth KPIs

## 🔄 Progress Monitoring Techniques

### Real-Time Indicators
```bash
# Watch for these status updates:
🎯 Mission: [MISSION] [INPUT-FILE] [STARTED]
├── @agent analyzing... [IN PROGRESS]
├── @agent working... [QUEUED]
└── @agent ready... [QUEUED]

# Completion signals:
✅ @agent: Task complete
🎯 Mission: [MISSION] [COMPLETE]
```

### Progress Files to Monitor
- **project-plan.md**: Tasks marked [x] as completed
- **progress.md**: Issues, solutions, lessons learned
- **handoff-notes.md**: Agent-to-agent context passing
- **evidence-repository.md**: Screenshots, code snippets, artifacts

### Status Commands
```bash
/coord status              # Current mission status
/coord resume [mission]    # Continue paused mission
/report today             # Progress summary
/report [date]            # Progress since date
```

## 🛠️ Recovery Procedures

### When Missions Stall
1. **Check Progress**: Review `progress.md` for logged issues
2. **Verify Input**: Ensure input file is complete and valid
3. **Resume Mission**: Re-run same command to continue
4. **Emergency Stop**: Use Ctrl+C and restart if necessary

### Common Problems & Solutions
| Problem | Symptoms | Solution |
|---------|----------|----------|
| **Input file not found** | "File not found" error | Use absolute file path |
| **Incomplete requirements** | Agent requests clarification | Fill all template sections |
| **Agent timeout** | No progress for 5+ minutes | Re-run command, work continues |
| **Conflicting constraints** | "Cannot resolve" error | Check `progress.md` for guidance |
| **Permission issues** | File access errors | Check file permissions |

### Emergency Commands
```bash
# If stuck or errors occur:
/coord status                    # Check what's happening
/coord resume [mission]         # Continue from checkpoint
/meeting @coordinator "stuck"   # Get help from coordinator

# If severe issues:
rm handoff-notes.md             # Clear agent context
/coord [mission] [input]        # Restart mission fresh
```

## 💡 Pro Tips for Better Results

### Input File Quality
1. **Be Specific**: "User login" → "OAuth with Google/GitHub, remember me option"
2. **Include Examples**: Show exactly what success looks like
3. **Set Clear Boundaries**: Define what's in/out of scope
4. **Provide Context**: Explain the "why" behind requirements
5. **Use Numbers**: Specific metrics, timelines, budgets

### Mission Selection Strategy
- **Start Simple**: Use `dev-alignment` before `build` for existing projects
- **MVP First**: Use `mvp` mission before building complex features
- **Fix Fast**: Use `fix` mission for quick bug resolution
- **Iterate Often**: Multiple small missions > one large mission

### Workflow Optimization
- **Template First**: Always start with official templates
- **Validate Early**: Test assumptions with simple missions
- **Document Everything**: Keep detailed notes in input files
- **Review Regularly**: Check progress files during long missions

## 🎯 Quick Troubleshooting Table

| Issue | Quick Fix | Prevention |
|-------|-----------|------------|
| Mission won't start | Check input file syntax | Use official templates |
| Agent seems stuck | Wait 2 minutes, then re-run | Provide more context in input |
| Unexpected results | Check `progress.md` for issues | Be more specific in requirements |
| Mission restarts | Input file was incomplete | Fill all template sections |
| Can't find files | Use absolute paths | Copy templates to project root |

## 📚 Additional Resources

### Template Library
- **Input Templates**: `/templates/mission-inputs/`
- **Project Templates**: `/templates/`
- **Mission Examples**: `/project/missions/`

### Documentation
- **Complete Mission Library**: `/project/missions/library.md`
- **Agent Capabilities**: `/project/agents/full-squad.md`
- **Architecture Guide**: `/project/field-manual/architecture-sop.md`

### Support
- **GitHub Issues**: Report bugs and request features
- **Community Examples**: `/project/community/`
- **Best Practices**: `/project/field-manual/`

---

## 🎖️ Mission Success Formula

**Successful Mission = Right Mission + Complete Input + Clear Objectives + Realistic Scope**

1. **Choose wisely**: Match mission to your specific goal
2. **Prepare thoroughly**: Use templates and fill completely
3. **Monitor actively**: Watch progress files and status updates
4. **Iterate quickly**: Small missions with fast feedback loops

**Remember**: AGENT-11 is designed for rapid iteration. Better to run 3 small missions successfully than 1 large mission that gets stuck.