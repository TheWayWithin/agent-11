#!/usr/bin/env python3
"""
Daily Report Enhancement Script
Transforms raw progress data into engaging, blog-ready content using LLM.

Usage:
    python3 enhance_dailyreport.py /path/to/progress/2025-11-26.md

Environment Variables:
    OPENAI_API_KEY: API key for OpenAI-compatible endpoint (required)
    DAILYREPORT_MODEL: Model to use (default: gpt-4.1-mini)
                       Options: gpt-4.1-mini, gpt-4.1-nano, gemini-2.5-flash
    DAILYREPORT_BASE_URL: API base URL (optional)
"""

import os
import sys
import json
import re
from datetime import datetime
from pathlib import Path

try:
    from openai import OpenAI
except ImportError:
    print("❌ Error: openai package not installed")
    print("   Install with: pip3 install openai")
    sys.exit(1)


class DailyReportEnhancer:
    def __init__(self):
        self.api_key = os.getenv("OPENAI_API_KEY")
        if not self.api_key:
            raise ValueError("OPENAI_API_KEY environment variable not set")
        
        # Configure model - use gpt-4.1-mini by default (fast and cost-effective)
        self.model = os.getenv("DAILYREPORT_MODEL", "gpt-4.1-mini")
        self.base_url = os.getenv("DAILYREPORT_BASE_URL")
        
        # Initialize OpenAI client
        if self.base_url:
            self.client = OpenAI(api_key=self.api_key, base_url=self.base_url)
        else:
            self.client = OpenAI(api_key=self.api_key)
    
    def parse_raw_report(self, content: str) -> dict:
        """Extract structured data from raw daily report."""
        data = {
            "date": None,
            "project_name": None,
            "completed_tasks": [],
            "issues_resolved": [],
            "impact_summary": None,
            "next_steps": []
        }
        
        # Extract date from title
        date_match = re.search(r'Progress Report - (.+)', content)
        if date_match:
            data["date"] = date_match.group(1)
        
        # Extract project name
        project_match = re.search(r'## Project: (.+)', content)
        if project_match:
            data["project_name"] = project_match.group(1)
        
        # Extract completed tasks
        completed_section = re.search(r'### ✅ Completed\n(.*?)(?=###|---|\Z)', content, re.DOTALL)
        if completed_section:
            tasks = re.findall(r'- (.+)', completed_section.group(1))
            data["completed_tasks"] = tasks
        
        # Extract issues
        issues_section = re.search(r'### 🐛 Issues & Learnings\n(.*?)(?=---|\Z)', content, re.DOTALL)
        if issues_section:
            issue_blocks = re.findall(
                r'#### Issue: (.+?)\n(.*?)(?=####|---|\Z)',
                issues_section.group(1),
                re.DOTALL
            )
            for title, details in issue_blocks:
                issue = {"title": title.strip()}
                
                root_cause = re.search(r'\*\*Root Cause\*\*: (.+)', details)
                if root_cause:
                    issue["root_cause"] = root_cause.group(1).strip()
                
                fix = re.search(r'\*\*Fix\*\*: (.+)', details)
                if fix:
                    issue["fix"] = fix.group(1).strip()
                
                prevention = re.search(r'\*\*Prevention\*\*: (.+)', details)
                if prevention:
                    issue["prevention"] = prevention.group(1).strip()
                
                time_impact = re.search(r'\*\*Time Impact\*\*: (.+)', details)
                if time_impact:
                    issue["time_impact"] = time_impact.group(1).strip()
                
                data["issues_resolved"].append(issue)
        
        # Extract impact summary
        impact_match = re.search(r'## Impact Summary\n(.+?)(?=##|\Z)', content, re.DOTALL)
        if impact_match:
            data["impact_summary"] = impact_match.group(1).strip()
        
        # Extract next steps
        next_steps_section = re.search(r'## Next Steps\n(.*?)(?=---|\Z)', content, re.DOTALL)
        if next_steps_section:
            steps = re.findall(r'- (.+)', next_steps_section.group(1))
            data["next_steps"] = steps
        
        return data
    
    def generate_llm_prompt(self, data: dict) -> str:
        """Generate the LLM prompt for content transformation."""
        return f"""You are a content writer helping a solo founder document their build-in-public journey.

Transform the following raw progress data into an engaging, blog-ready daily update post.

**Guidelines:**
- Write in first person, conversational tone
- Focus on storytelling, not task lists
- Explain technical concepts accessibly
- Highlight "why it matters" for each accomplishment
- Make challenges relatable and show the journey to resolution
- Keep it concise but engaging (300-500 words)
- Use markdown formatting with emojis
- Create an engaging title that captures the day's essence

**Raw Data:**
```json
{json.dumps(data, indent=2)}
```

**Output Format:**
# [Engaging Title] - Day X of {data.get('project_name', 'Project')}

> **TL;DR:** [One sentence capturing the day's essence]

## 🎯 Today's Focus
[1-2 sentence narrative about what was accomplished]

## ✨ Key Wins
[Write 2-3 major accomplishments as mini-stories, not bullet points. Each should explain what was built, why it matters, and the impact.]

## 💡 What I Learned
[Most interesting technical or product insight from today, written as a short paragraph]

## 🔧 Challenge of the Day
[If there were issues, write the main challenge as a story with beginning, middle, resolution. If no major challenges, write "Smooth sailing today! 🚢" and briefly mention any minor hurdles overcome.]

## 📊 Progress Snapshot
- **Completed:** [X] tasks
- **Momentum:** [🚀 High / 📈 Steady / 🐌 Slow]

## 🔮 Tomorrow's Mission
[1-2 sentences about next priority]

---

*Part of my build-in-public journey with {data.get('project_name', 'this project')}. Follow along for daily updates!*

**Tone:** Authentic, enthusiastic, transparent, educational
**Remember:** Transform technical jargon into accessible language. Make it feel like a conversation with a friend, not a status report."""

    def enhance_content(self, raw_content: str) -> str:
        """Use LLM to transform raw content into blog-ready format."""
        # Parse the raw report
        data = self.parse_raw_report(raw_content)
        
        # Generate LLM prompt
        prompt = self.generate_llm_prompt(data)
        
        # Call LLM
        try:
            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {
                        "role": "system",
                        "content": "You are an expert content writer specializing in build-in-public narratives and technical storytelling."
                    },
                    {
                        "role": "user",
                        "content": prompt
                    }
                ],
                temperature=0.7,
                max_tokens=1500
            )
            
            enhanced_content = response.choices[0].message.content
            return enhanced_content
            
        except Exception as e:
            raise Exception(f"LLM API call failed: {str(e)}")
    
    def process_file(self, input_path: str) -> tuple[str, str]:
        """Process a daily report file and return enhanced content and output path."""
        input_path = Path(input_path)
        
        if not input_path.exists():
            raise FileNotFoundError(f"Input file not found: {input_path}")
        
        # Read raw content
        with open(input_path, 'r', encoding='utf-8') as f:
            raw_content = f.read()
        
        # Enhance content
        enhanced_content = self.enhance_content(raw_content)
        
        # Determine output path
        output_path = input_path.parent / f"{input_path.stem}-blog.md"
        
        # Write enhanced content
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(enhanced_content)
        
        return enhanced_content, str(output_path)


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 enhance_dailyreport.py /path/to/progress/2025-11-26.md")
        sys.exit(1)
    
    input_file = sys.argv[1]
    
    try:
        print("🤖 Generating blog-ready version...")
        
        enhancer = DailyReportEnhancer()
        enhanced_content, output_path = enhancer.process_file(input_file)
        
        print(f"✨ Blog post created: {output_path}")
        print("📝 Ready to publish!")
        print()
        print("Preview:")
        print("━" * 60)
        # Print first 500 characters as preview
        preview = enhanced_content[:500] + "..." if len(enhanced_content) > 500 else enhanced_content
        print(preview)
        print("━" * 60)
        print()
        print(f"💡 Tip: Use {output_path} for your daily update post")
        
    except FileNotFoundError as e:
        print(f"❌ Error: {e}")
        sys.exit(1)
    except ValueError as e:
        print(f"❌ Configuration Error: {e}")
        print("   Make sure OPENAI_API_KEY is set in your environment")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Enhancement failed: {e}")
        print("   Falling back to standard format")
        sys.exit(1)


if __name__ == "__main__":
    main()
