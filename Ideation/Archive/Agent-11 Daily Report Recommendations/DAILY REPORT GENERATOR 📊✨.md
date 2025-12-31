---
name: dailyreport
description: Generate blog-ready daily progress reports with LLM enhancement
---

# DAILY REPORT GENERATOR 📊✨

**Command**: `/dailyreport`

**Purpose**: Extract today's completed work and issues from progress.md, then transform into engaging, blog-ready content using LLM enhancement.

## WHAT'S NEW? 🎉

The `/dailyreport` command now includes **automatic LLM enhancement** to transform raw progress data into engaging, narrative-driven blog posts perfect for build-in-public audiences.

### Before (Raw Format)
```markdown
### ✅ Completed
- Implemented authentication
- Fixed cookie bug
- Deployed to production
```

### After (Enhanced Format)
```markdown
## ✨ Key Wins
Today I shipped a complete authentication system that lets users log in 
with their GitHub accounts. This was a big milestone because it unlocks 
personalized features and user preferences. Along the way, I solved a 
tricky production issue where cookies weren't persisting correctly...
```

## HOW IT WORKS

1. **Extract** - Parse progress.md for today's entries
2. **Structure** - Organize into meaningful sections
3. **Enhance** - Transform with LLM into engaging narrative
4. **Output** - Generate both raw and blog-ready versions

## FILE OUTPUTS

```
/progress/
  2025-11-26.md          # Raw structured data (original format)
  2025-11-26-blog.md     # Enhanced blog-ready version (NEW!)
```

## COMMAND BEHAVIOR

### First Run of the Day

1. Check if `/progress/` directory exists, create if missing
2. Read `progress.md` from project root
3. Extract all deliverables, changes, issues, and completed items with today's date
4. Create `/progress/YYYY-MM-DD.md` with structured data
5. **[NEW]** Call enhancement script to generate blog-ready version
6. Output both files with preview

### Subsequent Runs Same Day

1. Check if `/progress/YYYY-MM-DD.md` already exists
2. Read existing file content
3. Extract NEW entries from progress.md since last run
4. Append new content to existing file
5. **[NEW]** Regenerate enhanced blog version with all content
6. Preserve existing content, only add new items

## ENHANCED OUTPUT FORMAT

The blog-ready version uses this engaging structure:

```markdown
# [Engaging Title] - Day X of [Project Name]

> **TL;DR:** [One sentence capturing the day's essence]

## 🎯 Today's Focus
[1-2 sentence narrative about what was accomplished]

## ✨ Key Wins
[2-3 major accomplishments written as mini-stories, explaining 
what was built, why it matters, and the impact]

## 💡 What I Learned
[Most interesting technical or product insight from today]

## 🔧 Challenge of the Day
[Main challenge written as a story with beginning, middle, 
resolution. Shows the journey, not just the fix]

## 📊 Progress Snapshot
- **Completed:** [X] tasks
- **Momentum:** [🚀 High / 📈 Steady / 🐌 Slow]

## 🔮 Tomorrow's Mission
[1-2 sentences about next priority]

---

*Part of my build-in-public journey with [Project]. Follow along!*
```

## CONFIGURATION

### Environment Variables

```bash
# Required for LLM enhancement
export OPENAI_API_KEY="your-api-key"

# Optional: Choose model (default: gpt-4.1-mini)
export DAILYREPORT_MODEL="gpt-4.1-mini"  # or gpt-4.1-nano, gemini-2.5-flash

# Optional: Disable enhancement (use raw format only)
export DAILYREPORT_ENABLE_ENHANCEMENT=false
```

### Supported Models

| Model | Speed | Cost | Best For |
|-------|-------|------|----------|
| `gpt-4.1-nano` | ⚡ Fastest | 💰 Cheapest | Quick daily updates |
| `gpt-4.1-mini` | 🚀 Fast | 💰💰 Low | **Recommended default** |
| `gemini-2.5-flash` | 🚀 Fast | 💰💰 Low | Alternative option |

## OUTPUT TO USER

### After First Run (With Enhancement)

```
✅ Raw report created: /progress/2025-11-26.md
📊 Captured 5 milestones across 3 categories
🐛 Documented 2 issues with root cause analysis

🤖 Generating blog-ready version...
✨ Blog post created: /progress/2025-11-26-blog.md
📝 Ready to publish!

Preview:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Shipped Authentication & Solved a Tricky Cookie Bug - Day 42

> **TL;DR:** Users can now log in with GitHub, and I learned 
> an important lesson about production testing.

## 🎯 Today's Focus
Today was all about getting authentication working smoothly...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 Tip: Use /progress/2025-11-26-blog.md for your daily update post
```

### After Update (Same Day)

```
✅ Raw report updated: /progress/2025-11-26.md
📊 Added 2 new milestones
🐛 Added 1 new issue analysis

🤖 Regenerating blog version with new content...
✨ Blog post updated: /progress/2025-11-26-blog.md
💡 Last updated: 3:45 PM
```

### If Enhancement Fails (Fallback)

```
✅ Raw report created: /progress/2025-11-26.md
⚠️ Blog enhancement unavailable, using standard format
💡 Check OPENAI_API_KEY environment variable
📝 Use /progress/2025-11-26.md for your daily update
```

## CONTENT TRANSFORMATION

### What the LLM Does

- **Adds narrative flow** - Connects tasks into a coherent story
- **Explains "why it matters"** - Provides context and impact
- **Makes technical concepts accessible** - Translates jargon
- **Creates engaging titles** - Captures the day's essence
- **Adds personality** - Conversational, authentic tone
- **Structures for scanning** - Clear hierarchy and sections

### What It Preserves

- **Accuracy** - All facts from raw data
- **Technical depth** - Doesn't oversimplify
- **Transparency** - Includes challenges and issues
- **Completeness** - All milestones represented

## STYLE GUIDELINES

The enhanced content follows these principles:

- **First person, conversational tone** - "I built" not "Built"
- **Past tense for completed work** - "Shipped" not "Shipping"
- **Focus on outcomes, not activities** - "Users can now..." not "Worked on..."
- **Accessible but not dumbed down** - Technical but clear
- **Honest about challenges** - Shows journey, not just wins
- **Concise but engaging** - 300-500 words total

## ERROR HANDLING

### If progress.md doesn't exist
```
❌ No progress.md found. Create one first to track your work.
```

### If no entries for today
```
✅ Template created: /progress/2025-11-26.md
ℹ️ No completed work logged for today
💡 Run again after updating progress.md
```

### If LLM enhancement fails
```
✅ Raw report created successfully
⚠️ Enhancement failed: [error message]
📝 Using standard format
💡 Check configuration and try again
```

### If API rate limit hit
```
⚠️ API rate limit reached, retrying...
[Automatic exponential backoff with 3 attempts]
```

## COST ESTIMATION

### Per Report (Typical)
- **Input tokens:** ~500 (raw progress data)
- **Output tokens:** ~800 (enhanced blog post)
- **Cost with gpt-4.1-mini:** ~$0.001 per report

### Monthly (Daily Reports)
- **30 reports:** ~$0.03/month
- **Annual:** ~$0.36/year

*Costs are estimates and may vary based on content length and model choice.*

## EXAMPLE USE CASE

```bash
# End of work day in agent-11 repo
/dailyreport

# Output:
# ✅ Raw report: /progress/2025-11-26.md
# ✨ Blog post: /progress/2025-11-26-blog.md

# Copy blog post to your daily update system
cp /progress/2025-11-26-blog.md ~/blog/posts/day-42.md

# Or use it directly in your build-in-public post
cat /progress/2025-11-26-blog.md
```

## INTEGRATION WITH AGENT-11

### Works Seamlessly With

- **progress.md** - Primary data source
- **project-plan.md** - Task completion verification
- **CLAUDE.md** - Project context and name
- **/report** - Longer-form progress reports
- **/pmd** - Root cause analysis for issues

### Enhancement Script

Located at: `project/commands/scripts/enhance_dailyreport.py`

Can be run manually if needed:
```bash
python3 project/commands/scripts/enhance_dailyreport.py /progress/2025-11-26.md
```

## BENEFITS

### For Solo Founders
- **Save time** - Automated content generation
- **Better engagement** - More readable, shareable posts
- **Authentic storytelling** - Shows journey, not just wins
- **Pattern recognition** - Track learnings over time

### For Build-in-Public
- **Increased readership** - Engaging content keeps followers
- **Accessibility** - Non-technical audience can follow along
- **Consistency** - Same quality every day
- **Transparency** - Honest about challenges

### For Personal Growth
- **Reflection ritual** - Daily review of work
- **Learning capture** - Document insights
- **Progress visibility** - See momentum over time
- **Knowledge base** - Reference for future projects

## BEST PRACTICES

### When to Run
1. **End of work day** - Capture full day's progress
2. **After major milestone** - Document significant achievements
3. **Before context switch** - Close out current project work

### How to Use Results
1. **Publish to blog** - Use `-blog.md` version directly
2. **Share on social** - Extract TL;DR and key wins
3. **Email updates** - Send to stakeholders or community
4. **Portfolio** - Showcase development journey
5. **Retrospectives** - Review patterns across days/weeks

### Tips for Best Results
1. **Keep progress.md detailed** - Better input = better output
2. **Run daily** - Consistency builds momentum
3. **Review and edit** - LLM is 90% there, add your voice
4. **Share challenges** - Transparency builds trust
5. **Celebrate wins** - Acknowledge progress, no matter how small

## TROUBLESHOOTING

### "Enhancement unavailable"
- Check OPENAI_API_KEY is set: `echo $OPENAI_API_KEY`
- Verify internet connection
- Check API quota/billing

### "Unsupported model"
- Use one of: gpt-4.1-mini, gpt-4.1-nano, gemini-2.5-flash
- Set DAILYREPORT_MODEL environment variable

### "No progress entries found"
- Ensure progress.md has today's date in entries
- Check date format: `### [YYYY-MM-DD HH:MM]`
- Verify progress.md exists in project root

### Output quality issues
- Provide more detail in progress.md
- Try different model (gpt-4.1-mini vs gemini-2.5-flash)
- Edit the enhanced version to match your voice

## FUTURE ENHANCEMENTS

Planned features:
- **Weekly summaries** - Aggregate 7 days into weekly post
- **Custom tone profiles** - Adjust for different audiences
- **Social media snippets** - Auto-generate Twitter/LinkedIn versions
- **Multi-project aggregation** - Combine multiple projects
- **Image generation** - Visual progress indicators

---

*The enhanced /dailyreport command transforms daily work into engaging stories, making build-in-public documentation effortless and authentic.*
