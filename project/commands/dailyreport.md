---
name: dailyreport
description: Generate consolidated daily progress reports for the current project
---

# DAILY REPORT GENERATOR 📊

**Command**: `/dailyreport`

**Purpose**: Extract today's completed work and issues from progress.md to create human-readable daily summary files for meaningful daily update blog posts.

## WHAT IS DAILYREPORT?

DailyReport is a progress consolidation command that generates structured daily summaries by parsing project tracking files to capture meaningful milestones, issues resolved, and learnings gained each day.

## KEY FEATURES

- **Automated Extraction**: Parses progress.md for today's entries automatically
- **Intelligent Grouping**: Consolidates related tasks into meaningful milestones
- **Issue Documentation**: Captures root cause analysis and prevention strategies
- **Incremental Updates**: Appends new progress when run multiple times same day
- **Blog-Ready Output**: Generates markdown optimized for daily update posts
- **AI Enhancement** (Optional): Transforms structured data into engaging narrative posts
- **Transparency**: Documents both wins and problems encountered

## AI ENHANCEMENT FEATURE

When `OPENAI_API_KEY` is configured, `/dailyreport` automatically generates TWO versions:

1. **Structured Report** (`YYYY-MM-DD.md`) - Raw data with checkboxes and sections
2. **Blog-Ready Post** (`YYYY-MM-DD-blog.md`) - AI-enhanced narrative version

### What AI Enhancement Does

- Transforms task lists into engaging stories
- Makes technical concepts accessible to non-technical readers
- Adds narrative flow and emotional connection
- Highlights "why it matters" for each accomplishment
- Structures challenges as problem → solution journeys

### Cost & Performance

- **Per report**: ~$0.001 (less than a penny)
- **Processing time**: ~5 seconds
- **Model**: gpt-4.1-mini (configurable via `DAILYREPORT_MODEL`)

### Configuration

Add to your `.env.mcp` file:

```bash
# Required for AI enhancement
OPENAI_API_KEY=your_openai_key_here

# Optional: Choose model (default: gpt-4.1-mini)
DAILYREPORT_MODEL=gpt-4.1-mini    # Recommended (balanced)
# DAILYREPORT_MODEL=gpt-4.1-nano  # Faster/cheaper
# DAILYREPORT_MODEL=gemini-2.5-flash  # Alternative

# Optional: Disable enhancement
DAILYREPORT_ENABLE_ENHANCEMENT=true
```

### Setup Instructions

```bash
# 1. Copy environment template
cp .env.mcp.template .env.mcp

# 2. Edit and add your OpenAI API key
vim .env.mcp

# 3. Get an API key from: https://platform.openai.com/api-keys

# 4. Run dailyreport - enhancement happens automatically
/dailyreport
```

### Fallback Behavior

If `OPENAI_API_KEY` is not set or the enhancement fails:
- ✅ Standard structured report is still created
- ℹ️ User is notified that enhancement is unavailable
- 📝 Instructions provided for enabling enhancement

## SCOPE

- Runs in a **single project repository**
- Creates report only for the current project
- Should be run at end of day or when significant milestones are reached

## FILE STRUCTURE

```
/progress/
  2025-11-19.md          # Structured report (always created)
  2025-11-19-blog.md     # Blog-ready narrative (created if OPENAI_API_KEY set)
  2025-11-20.md
  2025-11-20-blog.md
  2025-11-21.md
  2025-11-21-blog.md
  ...
```

## FILE NAMING CONVENTION

- **Format**: `YYYY-MM-DD.md` (ISO 8601 date format)
- **Location**: `/progress/` directory in project root
- **Example**: `/progress/2025-11-19.md`

## COMMAND BEHAVIOR

### First Run of the Day

1. Check if `/progress/` directory exists, create if missing
2. Read `progress.md` from project root
3. Extract all deliverables, changes, issues, and completed items with today's date
4. Group by context (features, fixes, infrastructure, etc.)
5. Create new `/progress/YYYY-MM-DD.md` file using the template
6. Summarize completed tasks into meaningful milestones (not raw checkboxes)
7. Extract issues with root cause analysis and fixes
8. Add impact statement and next steps
9. **If OPENAI_API_KEY is set**: Call enhancement script to generate blog-ready version
   - Run: `python3 project/commands/scripts/enhance_dailyreport.py /progress/YYYY-MM-DD.md`
   - Creates: `/progress/YYYY-MM-DD-blog.md` with narrative version
   - If enhancement fails: Log error but continue (structured report already created)

### Subsequent Runs Same Day

1. Check if `/progress/YYYY-MM-DD.md` already exists
2. Read existing file content
3. Read `progress.md` for any NEW entries since last run
4. Append new milestones to existing sections
5. Add any new issues to the Issues & Learnings section
6. Update impact statement if needed
7. Preserve existing content, only add new items

## MARKDOWN TEMPLATE

```markdown
# Progress Report - [Month Day, Year]

## Project: [Project Name from repo]

### ✅ Completed
- [Completed milestone description]
- [Another completed milestone]
- [Major feature or fix shipped]

### 🐛 Issues & Learnings
#### Issue: [Brief issue description]
- **Root Cause**: [What actually caused the problem]
- **Fix**: [How it was resolved]
- **Prevention**: [How to avoid this in the future]
- **Time Impact**: [How long it took to resolve]

#### Issue: [Another issue if applicable]
- **Root Cause**: [Analysis]
- **Fix**: [Solution]
- **Prevention**: [Future safeguard]
- **Time Impact**: [Duration]

---

## Impact Summary
[2-3 sentence summary of what was achieved today and why it matters]

## Next Steps
- [Key priority for tomorrow]
- [Upcoming milestone]

---

_Generated from progress.md on [Date] at [Time]_
_Last updated: [Time] (if run multiple times)_
```

## CONTENT GUIDELINES

### What to INCLUDE in Completed Section

- ✅ Completed features, fixes, and deployments
- ✅ Meaningful milestones (group related tasks)
- ✅ Shipped work that's visible/measurable
- ✅ Major decisions or architecture changes
- ✅ Successful test results or validations

### What to INCLUDE in Issues & Learnings

- 🐛 Problems encountered and resolved today
- 🐛 Root cause analysis from progress.md entries
- 🐛 Solutions implemented
- 🐛 Prevention strategies identified
- 🐛 Time spent on debugging/fixing (if recorded)
- 🐛 Key technical learnings from failures

### What to EXCLUDE

- ❌ Raw task checkbox text from project-plan.md
- ❌ In-progress work (unless it's a significant partial milestone)
- ❌ Trivial changes (typo fixes, minor refactoring)
- ❌ Unresolved issues (those stay in progress.md only)
- ❌ Administrative tasks (unless project-critical)

## STYLE GUIDELINES

- **Use past tense**: "Built", "Shipped", "Fixed" (not "Building", "Working on")
- **Focus on outcomes**: Not activities
- **Group related items**: Consolidate into single milestone where possible
- **Meaningful bullets**: Each should be blog-worthy
- **Aim for 3-8 milestones per day**: Consolidate smaller tasks
- **Technical depth for issues**: Be specific about root cause and fix

## DATE PARSING LOGIC

- Extract dates from progress.md entries in format: `### [YYYY-MM-DD HH:MM]` or `## [Month Day, Year]`
- Match today's date (use system date as reference)
- If timestamp found, compare date portion only (ignore time)

## PROGRESS.MD STRUCTURE REFERENCE

The command should parse entries like:

### Deliverables

```markdown
### [2025-11-19 14:30] Feature Completion
**What Was Done**:
- Implemented X feature
- Added Y functionality
- Deployed to production
```

### Issues

```markdown
### [2025-11-19 10:15] Bug Fix - Authentication Issue

**What Happened**:
- Users couldn't log in with GitHub OAuth
- Error: "Invalid state parameter"

**Root Cause**:
- Session cookie wasn't being set due to SameSite policy in production
- Development environment didn't catch this because localhost doesn't enforce SameSite=None

**Fix**:
- Updated cookie settings to SameSite=None; Secure=true for production
- Added environment detection to handle dev vs production properly

**Prevention**:
- Add production-like testing environment
- Document cookie security requirements in deployment checklist
```

## ERROR HANDLING

- **If progress.md doesn't exist**: Inform user and exit gracefully with message: "No progress.md found. Create one first to track your work."
- **If no entries for today**: Create template with note "No completed work logged for today. Run again after updating progress.md."
- **If /progress/ directory can't be created**: Report error with suggestion to check permissions
- **If project name can't be determined**: Use "Current Project" as fallback

## PROJECT NAME DETECTION

Try these methods in order:
1. Read from package.json "name" field
2. Read from CLAUDE.md project overview section
3. Use repository directory name
4. Fallback: "Current Project"

## OUTPUT TO USER

### After First Run (With AI Enhancement)

```
✅ Daily report created: /progress/2025-11-19.md
📊 Captured 5 milestones across 3 categories
🐛 Documented 2 issues with root cause analysis
🤖 Generating blog-ready version...
✨ Blog post created: /progress/2025-11-19-blog.md
📝 Ready to publish!

Preview:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# When Docs Lie: Hunting Down a Ghost Bug – Day 42 of AGENT-11

> TL;DR: I uncovered a sneaky bug hiding behind perfect documentation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 Tip: Use /progress/2025-11-19-blog.md for your daily update post
```

### After First Run (Without AI Enhancement)

```
✅ Daily report created: /progress/2025-11-19.md
📊 Captured 5 milestones across 3 categories
🐛 Documented 2 issues with root cause analysis
💡 Run again today to append additional progress
📝 Use this file for daily update generation

ℹ️  AI Enhancement Available:
   Add OPENAI_API_KEY to .env.mcp to generate blog-ready posts automatically
   See: https://platform.openai.com/api-keys
```

### After Update

```
✅ Daily report updated: /progress/2025-11-19.md
📊 Added 2 new milestones
🐛 Added 1 new issue analysis
💡 Last updated: 3:45 PM
🤖 Blog version regenerated: /progress/2025-11-19-blog.md
```

## INTEGRATION WITH DAILY UPDATE SYSTEM

This file will be consumed by the daily update generator in `/admin/content`. The generator should:

1. Check for `/progress/YYYY-MM-DD.md` file in each project
2. If exists, use this instead of parsing project-plan.md
3. Parse markdown sections as structured content
4. Include Issues & Learnings section in daily updates (shows transparency)
5. Use Impact Summary as excerpt base

## EXAMPLE USE CASE

```bash
# In JamieWatters portfolio repo, end of work day
/dailyreport
# Output: Creates /progress/2025-11-19.md with today's portfolio work

# Later same day, shipped another feature
# Update progress.md with new completion
/dailyreport
# Output: Updates /progress/2025-11-19.md with new milestone

# In Trader-7 repo, different day
cd ../Trader-7
/dailyreport
# Output: Creates /progress/2025-11-20.md for Trader-7 project
```

## MULTI-PROJECT DAILY UPDATES

When generating daily updates across multiple projects:

1. Check each project's `/progress/YYYY-MM-DD.md` file
2. Combine into single daily update post
3. Each project becomes a section in the post
4. Issues & Learnings can be combined or kept per-project

## BENEFITS OF INCLUDING ISSUES

- **Authentic Build-in-Public**: Shows journey, not just wins
- **Learning Documentation**: Captures knowledge for future reference
- **Pattern Recognition**: Helps identify recurring problem types
- **Credibility Building**: Provides valuable context for daily updates

## BENEFITS

### For Solo Founders
- Quick daily summary generation
- Blog-ready content for transparency
- Pattern recognition across issues
- Time-boxed reflection ritual

### For Development Teams
- Shared understanding of daily progress
- Visibility into challenges faced
- Learning from issue resolutions
- Streamlined stakeholder updates

### For Stakeholders
- Clear progress visibility
- Honest issue disclosure
- Impact-focused summaries
- Confidence in development process

## BEST PRACTICES

### When to Run DailyReport

1. End of work day
2. After significant milestone completion
3. Before daily standup/update
4. When switching contexts between projects

### How to Use Results

1. Use as daily blog post source material
2. Include in stakeholder emails
3. Track patterns across multiple days
4. Reference during retrospectives
5. Share learnings with community

## INTEGRATION WITH AGENT-11

DailyReport works seamlessly with:

- **progress.md**: Primary data source for all logged work and issues
- **project-plan.md**: Secondary source for task completion verification
- **CLAUDE.md**: Project context for name and overview
- **/report**: Complementary command for longer-form progress reports
- **/pmd**: Root cause analysis feeds into issue documentation

---

*The /dailyreport command transforms daily work into shareable progress summaries, enabling authentic build-in-public documentation and systematic learning capture.*
