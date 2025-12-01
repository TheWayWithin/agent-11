---
name: dailyreport
description: Generate consolidated daily progress reports with AI-enhanced blog and social media posts
---

# /dailyreport Command

Automated daily progress capture, blog generation, and social media post creation for build-in-public documentation. Tracks milestones, issues, and lessons learned while generating AI-enhanced blog posts and platform-optimized social media content.

## KEY FEATURES

- **Automatic Progress Capture**: Creates structured daily report capturing milestones, issues, lessons, and metrics
- **Blog Post Generation**: AI-enhanced blog-ready versions optimized for technical audience
- **Social Media Posts**: Platform-optimized Twitter/X and LinkedIn posts for build-in-public sharing
- **Structured Metadata**: Captures project context, timestamps, and categorization
- **Build-in-Public Ready**: Copy-paste social posts with character count validation
- **Cost Efficient**: ~$0.002 per complete report (blog + social)
- **Lightning Fast**: ~5 seconds for full report generation with blog and social posts

## WHAT IT DOES

### First Run of the Day

When you run `/dailyreport` for the first time in a day, it creates your initial daily report capturing:

```
✅ Daily report created: /progress/2025-11-19.md
📊 Captured 5 milestones across 3 categories
🐛 Documented 2 issues with root cause analysis
🤖 Generating blog-ready version...
✨ Blog post created: /progress/2025-11-19-blog.md
🐦 Generating social media posts...
✨ Twitter post created: /progress/2025-11-19-twitter.md
✨ LinkedIn post created: /progress/2025-11-19-linkedin.md
📝 Ready to publish!

Twitter Preview (copy-paste ready):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Shipped bulletproof file persistence today 🚀

Learned that agents can silently fail - fixed it for good.

Full writeup: jamiewatters.work/progress/2025-11-19

#buildinpublic
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 Files ready:
   - /progress/2025-11-19-blog.md (blog post)
   - /progress/2025-11-19-twitter.md (Twitter/X)
   - /progress/2025-11-19-linkedin.md (LinkedIn)
```

### Subsequent Runs

Running `/dailyreport` later the same day appends to existing daily report:

```
✅ Daily report updated: /progress/2025-11-19.md
📊 Total: 8 milestones across 4 categories
🐛 Total issues: 3
🤖 Regenerating blog-ready version...
✨ Blog post updated: /progress/2025-11-19-blog.md
🐦 Regenerating social media posts...
✨ Twitter post updated: /progress/2025-11-19-twitter.md
✨ LinkedIn post updated: /progress/2025-11-19-linkedin.md
📝 Ready to publish!
```

## AI ENHANCEMENT FEATURE

### Blog Post Generation

When enabled (default), `/dailyreport` generates a polished blog-ready version of your daily report.

**Blog Output** (`YYYY-MM-DD-blog.md`):
- Narrative structure with engaging introduction
- Categorized milestones with context and impact
- Issue analysis with root cause explanations
- Lessons learned and patterns discovered
- Technical depth appropriate for developer audience
- 5-10 minute read length

**Configuration**:
```bash
# Required for AI features
OPENAI_API_KEY=your_openai_key_here
```

### Social Media Post Generation

When enabled (default), `/dailyreport` generates platform-optimized social media posts for Twitter/X and LinkedIn.

**Social Media Output**:
- `YYYY-MM-DD-twitter.md` - Twitter/X post (280 char limit, 71-100 optimal)
- `YYYY-MM-DD-linkedin.md` - LinkedIn post (800-1000 character sweet spot)
- Copy-paste ready format with character count validation
- Platform-specific tone and engagement patterns
- Links to full progress post

**Configuration**:
```bash
# Enable/disable social media generation (default: true)
DAILYREPORT_ENABLE_SOCIAL=true

# Base URL for progress links (default: jamiewatters.work)
DAILYREPORT_BASE_URL=jamiewatters.work
```

## SOCIAL MEDIA POST GENERATION

When social media generation is enabled, `/dailyreport` automatically creates platform-optimized posts alongside your blog content.

### Platforms Supported

**Twitter/X**:
- 280 character hard limit (aims for 71-100 optimal)
- 1-2 hashtags from: #buildinpublic #solofounder #indiehacker #devlog
- Strong hook + accomplishment + link pattern
- Behind-the-scenes, authentic tone

**LinkedIn**:
- 800-1000 character sweet spot (3,000 max)
- First 140 characters optimized as hook (shown before "see more")
- Short one-line phrases for scannability
- Ends with engagement question
- Professional yet authentic developer/founder tone

### Output Files

| File | Platform | Format |
|------|----------|--------|
| `YYYY-MM-DD-twitter.md` | Twitter/X | Copy-paste ready with character count |
| `YYYY-MM-DD-linkedin.md` | LinkedIn | Copy-paste ready with hook validation |

### Cost & Performance

- **Per report**: ~$0.001 additional (combined with blog = ~$0.002 total)
- **Processing time**: ~3-5 seconds additional
- **Model**: gpt-4o-mini (same as blog generation)

## FILE STRUCTURE

Daily reports create a consistent file structure in `/progress/` directory:

```
progress/
├── 2025-11-19.md              # Raw daily report (source of truth)
├── 2025-11-19-blog.md         # Blog post (AI-enhanced narrative)
├── 2025-11-19-twitter.md      # Twitter/X post (280 char)
└── 2025-11-19-linkedin.md     # LinkedIn post (800-1000 char)

├── 2025-11-20.md              # Next day report
├── 2025-11-20-blog.md         # Blog version
├── 2025-11-20-twitter.md      # Twitter/X version
└── 2025-11-20-linkedin.md     # LinkedIn version
```

## COMMAND USAGE

### Basic Usage

```bash
/dailyreport
```

Automatically:
1. Captures your progress for the day
2. Generates blog-ready narrative version
3. Generates Twitter/X post (if enabled)
4. Generates LinkedIn post (if enabled)
5. Displays preview of generated posts
6. Returns file paths for publishing

### Environment Configuration

Add to your `.env.mcp` file:

```bash
# Required for AI enhancement
OPENAI_API_KEY=your_openai_key_here

# Optional: Choose model (default: gpt-4o-mini)
DAILYREPORT_MODEL=gpt-4o-mini

# Enable/disable social media generation (default: true)
DAILYREPORT_ENABLE_SOCIAL=true

# Base URL for progress links (default: jamiewatters.work)
DAILYREPORT_BASE_URL=jamiewatters.work
```

## OUTPUT TO USER

### First Daily Report (With AI Enhancement)

```
✅ Daily report created: /progress/2025-11-19.md
📊 Captured 5 milestones across 3 categories
🐛 Documented 2 issues with root cause analysis

AI Enhancement Enabled:
🤖 Generating blog-ready version...
✨ Blog post created: /progress/2025-11-19-blog.md

🐦 Generating social media posts...
✨ Twitter post created: /progress/2025-11-19-twitter.md
✨ LinkedIn post created: /progress/2025-11-19-linkedin.md

📝 Ready to publish!

Twitter Preview (copy-paste ready):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Shipped bulletproof file persistence today 🚀

Learned that agents can silently fail - fixed it for good.

Full writeup: jamiewatters.work/progress/2025-11-19

#buildinpublic
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 Files ready:
   - Raw Report: /progress/2025-11-19.md
   - Blog Post: /progress/2025-11-19-blog.md
   - Twitter/X: /progress/2025-11-19-twitter.md
   - LinkedIn: /progress/2025-11-19-linkedin.md
```

### Without AI Enhancement

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

## PUBLISHING WORKFLOW

### Twitter/X Publishing

1. Open `/progress/YYYY-MM-DD-twitter.md`
2. Copy the post text (between the dashed lines)
3. Paste into Twitter/X compose
4. Click Tweet

### LinkedIn Publishing

1. Open `/progress/YYYY-MM-DD-linkedin.md`
2. Copy the post text (between the dashed lines)
3. Go to LinkedIn home feed
4. Click "Start a post"
5. Paste content
6. Click "Post"

### Blog Publishing

1. Open `/progress/YYYY-MM-DD-blog.md`
2. Verify formatting and content
3. Publish to your blog platform
4. Share blog link in social posts

## TROUBLESHOOTING

### Social Posts Not Generating

**Check if disabled**:
```bash
grep "DAILYREPORT_ENABLE_SOCIAL" .env.mcp
```

**Enable if disabled**:
```bash
echo "DAILYREPORT_ENABLE_SOCIAL=true" >> .env.mcp
```

### Character Count Issues

**Twitter/X Post Too Long**:
- Character limit: 280 (hard limit)
- Optimal: 71-100 characters
- Solution: Re-run to regenerate, or manually edit

**LinkedIn Hook Too Long**:
- First 140 chars shown before "see more"
- Check optimization notes in output file

### Missing Files

**Only Raw Report Created**:
- Indicates AI enhancement is disabled or API key missing
- Add `OPENAI_API_KEY` to `.env.mcp`
- Set `DAILYREPORT_ENABLE_SOCIAL=true`

## INTEGRATION WITH AGENT-11

DailyReport works seamlessly with:

- **progress.md**: Primary data source for all logged work and issues
- **project-plan.md**: Secondary source for task completion verification
- **CLAUDE.md**: Project context for name and overview
- **/report**: Complementary command for longer-form progress reports
- **/pmd**: Root cause analysis feeds into issue documentation

## QUICK REFERENCE

| Task | Command/Setting |
|------|-----------------|
| Create daily report | `/dailyreport` |
| Enable social posts | `DAILYREPORT_ENABLE_SOCIAL=true` |
| Set custom domain | `DAILYREPORT_BASE_URL=yourdomain.com` |
| View today's report | `cat progress/$(date +%Y-%m-%d).md` |
| View today's twitter | `cat progress/$(date +%Y-%m-%d)-twitter.md` |
| View today's linkedin | `cat progress/$(date +%Y-%m-%d)-linkedin.md` |

## COST & EFFICIENCY

**Per Complete Report** (blog + social):
- API cost: ~$0.002
- Processing time: 3-5 seconds
- Manual effort saved: 15-20 minutes

**Monthly Estimate** (daily reports):
- 30 reports × $0.002 = $0.06
- Time saved: 7.5-10 hours

---

*The /dailyreport command transforms daily work into shareable progress summaries, enabling authentic build-in-public documentation with platform-optimized social media posts.*
