# Enhanced /dailyreport Quick Start Guide

Transform your daily progress reports from task lists into engaging blog posts in 5 minutes.

---

## What You Get

**Before:**
```markdown
### ✅ Completed
- Implemented authentication
- Fixed cookie bug
- Deployed to production
```

**After:**
```markdown
## ✨ Key Wins
Today I shipped a complete authentication system that lets users 
log in with their GitHub accounts. This was a big milestone because 
it unlocks personalized features...
```

---

## Installation (2 minutes)

### Step 1: Copy the Enhancement Script

```bash
cd /path/to/agent-11
cp /path/to/enhance_dailyreport.py project/commands/scripts/
chmod +x project/commands/scripts/enhance_dailyreport.py
```

### Step 2: Install Dependencies

```bash
pip3 install openai
```

### Step 3: Verify Configuration

```bash
# Check that your API key is set
echo $OPENAI_API_KEY

# If not set, add to your shell profile:
export OPENAI_API_KEY="your-api-key-here"
```

---

## Usage (30 seconds)

### Basic Usage

```bash
# Run at end of day
/dailyreport

# You'll get two files:
# /progress/2025-11-26.md        (raw data)
# /progress/2025-11-26-blog.md   (blog-ready)
```

### Manual Enhancement

```bash
# If you want to enhance an existing report
python3 project/commands/scripts/enhance_dailyreport.py /progress/2025-11-26.md
```

---

## Configuration Options

### Choose a Different Model

```bash
# Use the fastest, cheapest option
export DAILYREPORT_MODEL="gpt-4.1-nano"

# Use the default (recommended)
export DAILYREPORT_MODEL="gpt-4.1-mini"

# Use Google's model
export DAILYREPORT_MODEL="gemini-2.5-flash"
```

### Disable Enhancement

```bash
# Fall back to standard format only
export DAILYREPORT_ENABLE_ENHANCEMENT=false
```

---

## Cost

- **Per report:** ~$0.001
- **Daily for a month:** ~$0.03
- **Daily for a year:** ~$0.36

Negligible cost for significantly better content!

---

## Troubleshooting

### "Enhancement unavailable"

**Problem:** API key not set or invalid

**Solution:**
```bash
export OPENAI_API_KEY="your-key-here"
```

### "Unsupported model"

**Problem:** Wrong model name

**Solution:** Use one of these:
- `gpt-4.1-mini` (recommended)
- `gpt-4.1-nano` (fastest)
- `gemini-2.5-flash` (alternative)

### Output quality issues

**Problem:** Generic or inaccurate content

**Solution:** Add more detail to your progress.md entries. The LLM can only work with the data you provide!

---

## Tips for Best Results

1. **Write detailed progress entries** - Include context, not just task names
2. **Document challenges** - The "Challenge of the Day" section is gold
3. **Run daily** - Consistency builds momentum
4. **Edit before publishing** - LLM gets you 90% there, add your voice
5. **Share challenges** - Transparency builds trust

---

## Example Workflow

```bash
# Morning: Start work
# (work throughout the day, updating progress.md)

# End of day: Generate report
/dailyreport

# Review the blog version
cat /progress/2025-11-26-blog.md

# Make any personal edits
vim /progress/2025-11-26-blog.md

# Publish to your blog
cp /progress/2025-11-26-blog.md ~/blog/posts/day-42.md
git add ~/blog/posts/day-42.md
git commit -m "Day 42 update"
git push

# Share on social media
# (Copy TL;DR and link to blog post)
```

---

## What's Next?

- Try different models to find your preferred style
- Experiment with editing the prompt for custom tone
- Use the raw data file for programmatic processing
- Build weekly summaries from daily reports

---

## Need Help?

- **Documentation:** See `dailyreport-implementation-guide.md`
- **Script location:** `project/commands/scripts/enhance_dailyreport.py`
- **Command spec:** `project/commands/dailyreport-enhanced.md`

---

**Happy building in public! 🚀**
