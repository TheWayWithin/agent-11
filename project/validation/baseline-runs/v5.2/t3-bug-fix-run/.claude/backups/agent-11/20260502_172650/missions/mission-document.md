# Mission: DOCUMENT 📚
## Comprehensive Documentation Creation and Maintenance

**Mission Code**: DOCUMENT  
**Estimated Duration**: 2-4 hours  
**Complexity**: Medium  
**Squad Required**: Documenter, Developer, Architect

## Mission Briefing

Create comprehensive, user-friendly documentation that enables team members and users to understand, use, and contribute to your project effectively. Transform complex systems into clear, actionable documentation.

## Required Inputs

1. **System/Feature to Document** (required) - Codebase, API, or feature
2. **Target Audience** (optional) - Developers, users, contributors
3. **Existing Documentation** (optional) - Current docs to update/expand

## Mission Phases

### Phase 1: Documentation Audit and Planning (30-45 minutes)
**Lead**: @documenter  
**Support**: @architect  
**Objective**: Assess current state and plan comprehensive documentation

**Tasks**:
- Audit existing documentation for gaps and accuracy
- Identify target audiences and their needs
- Map system architecture and key components
- Define documentation structure and priorities
- Plan information architecture

**Success Criteria**:
- Documentation gaps identified
- Target audience needs defined
- Documentation structure planned
- Priority areas established

### Phase 2: Technical Architecture Documentation (45-60 minutes)
**Lead**: @architect  
**Support**: @developer, @documenter  
**Objective**: Document system architecture and technical decisions

**Tasks**:
- Create system architecture diagrams
- Document key technical decisions and rationale
- Map data flows and system integrations
- Document deployment and infrastructure
- Create troubleshooting guides

**Success Criteria**:
- Architecture clearly documented
- Technical decisions explained
- System integrations mapped
- Infrastructure documented

### Phase 3: API and Interface Documentation (45-60 minutes)
**Lead**: @developer  
**Support**: @documenter  
**Objective**: Create comprehensive API and interface documentation

**Tasks**:
- Document all API endpoints with examples
- Create interface specifications and schemas
- Generate code examples and usage patterns
- Document authentication and authorization
- Create integration guides

**Success Criteria**:
- All APIs documented with examples
- Authentication methods clear
- Integration guides complete
- Code examples functional

### Phase 4: User Guide and Tutorial Creation (60-90 minutes)
**Lead**: @documenter  
**Support**: @developer  
**Objective**: Create user-friendly guides and tutorials

**Tasks**:
- Write getting started guide
- Create step-by-step tutorials
- Document common use cases and workflows
- Create troubleshooting and FAQ sections
- Add screenshots and visual aids

**Success Criteria**:
- Getting started guide complete
- Key workflows documented
- Troubleshooting guide comprehensive
- Visual aids enhance understanding

### Phase 5: Code Documentation and Comments (30-45 minutes)
**Lead**: @developer  
**Support**: @documenter  
**Objective**: Ensure code is well-documented inline

**Tasks**:
- Add comprehensive code comments
- Update function and class documentation
- Document complex algorithms and business logic
- Add usage examples in code
- Review and improve naming conventions

**Success Criteria**:
- Code properly commented
- Complex logic explained
- Usage examples included
- Naming conventions consistent

### Phase 6: Review and Publication (15-30 minutes)
**Lead**: @documenter  
**Support**: @architect, @developer  
**Objective**: Review, refine, and publish documentation

**Tasks**:
- Review all documentation for accuracy and clarity
- Test all code examples and links
- Organize content for easy navigation
- Publish documentation to appropriate platform
- Set up documentation maintenance process

**Success Criteria**:
- Documentation reviewed and accurate
- All examples tested and working
- Content well-organized
- Publication successful

## Documentation Types Covered

### Technical Documentation
- **Architecture Documentation**: System design, components, data flow
- **API Documentation**: Endpoints, parameters, responses, examples
- **Code Documentation**: Inline comments, function docs, examples
- **Deployment Documentation**: Setup, configuration, troubleshooting

### User Documentation
- **Getting Started Guide**: Installation, setup, first steps
- **User Manual**: Feature documentation, workflows, best practices
- **Tutorials**: Step-by-step guides for common tasks
- **FAQ and Troubleshooting**: Common issues and solutions

### Process Documentation
- **Contributing Guidelines**: How to contribute to the project
- **Development Setup**: Local development environment setup
- **Release Process**: How releases are planned and executed
- **Support Process**: How to get help and report issues

## Common Variations

### API Documentation Focus
- **Duration**: 2-3 hours
- **Focus**: Comprehensive API documentation with examples
- **Tools**: OpenAPI/Swagger, Postman collections

### User Guide Focus
- **Duration**: 3-4 hours
- **Focus**: End-user documentation and tutorials
- **Tools**: Screenshots, videos, interactive guides

### Code Documentation Overhaul
- **Duration**: 4-6 hours
- **Focus**: Comprehensive inline documentation
- **Tools**: Code documentation generators, style guides

### Migration Documentation
- **Duration**: 2-3 hours
- **Focus**: Migration guides and breaking changes
- **Tools**: Version comparison, migration scripts

## Success Metrics

- **Documentation Coverage**: All major features documented
- **User Adoption**: Reduced support requests, faster onboarding
- **Developer Productivity**: Faster development, fewer questions
- **Accuracy**: Up-to-date information, working examples
- **Accessibility**: Easy to find, understand, and use

## Tools and Platforms

### Documentation Platforms
- **GitBook**: Comprehensive documentation sites
- **Notion**: Collaborative documentation
- **GitHub Pages**: Simple documentation hosting
- **Confluence**: Enterprise documentation

### Documentation Generators
- **JSDoc**: JavaScript documentation
- **Sphinx**: Python documentation
- **GitBook**: Multi-format documentation
- **Swagger/OpenAPI**: API documentation

### Visual Tools
- **Miro/Figma**: Architecture diagrams
- **Screenshots**: Step-by-step guides
- **Screen recordings**: Video tutorials
- **Diagrams as Code**: Automated diagrams

## Maintenance Strategy

### Regular Reviews
- **Monthly**: Check for outdated information
- **Release-based**: Update with new features
- **Quarterly**: Comprehensive review and reorganization
- **As-needed**: Fix broken links and examples

### Community Contribution
- **Feedback Loop**: Collect user feedback on documentation
- **Contribution Guidelines**: Enable community contributions
- **Review Process**: Maintain quality while accepting help
- **Recognition**: Acknowledge documentation contributors

## Integration Points

- **Follows**: BUILD, REFACTOR, INTEGRATE missions
- **Enables**: Better onboarding, reduced support load
- **Coordinates with**: Release management, support processes
- **Requires**: Access to system, understanding of user needs

---

**Mission Command**: `/coord document [system-feature] [target-audience] [existing-docs]`

*"Good documentation is like a bridge between complex systems and human understanding."*

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