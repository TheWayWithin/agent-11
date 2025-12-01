#!/usr/bin/env python3
"""
Daily Report AI Enhancement Script

Enhances raw daily progress reports with AI-generated blog posts and social media content.

Features:
- Converts raw progress logs to polished blog posts
- Generates Twitter/X posts (280 char limit, build-in-public style)
- Generates LinkedIn posts (800-1000 chars, professional tone)
- Auto-generates links to progress archives
- Validates character counts and formatting

Environment Variables:
    OPENAI_API_KEY: Required for AI enhancement features
    DAILYREPORT_ENABLE_SOCIAL: Enable social media generation (default: true)
    DAILYREPORT_BASE_URL: Base URL for links (default: jamiewatters.work)

Usage:
    python enhance_dailyreport.py <input_file>
    python enhance_dailyreport.py progress/2025-11-29.md
"""

import os
import sys
import json
import re
from datetime import datetime
from pathlib import Path
from typing import Dict, Optional, Tuple

try:
    from openai import OpenAI
except ImportError:
    print("Error: openai package not installed")
    print("Install with: pip install openai")
    sys.exit(1)


class DailyReportEnhancer:
    """Enhances daily progress reports with AI-generated content."""

    def __init__(self):
        """Initialize the enhancer with OpenAI client."""
        self.api_key = os.getenv('OPENAI_API_KEY')
        if not self.api_key:
            raise ValueError(
                "OPENAI_API_KEY environment variable not set. "
                "Get your key from: https://platform.openai.com/api-keys"
            )

        self.client = OpenAI(api_key=self.api_key)
        self.model = "gpt-4o-mini"  # Cost-effective model for content generation

        # Configuration
        self.enable_social = os.getenv('DAILYREPORT_ENABLE_SOCIAL', 'true').lower() == 'true'
        self.base_url = os.getenv('DAILYREPORT_BASE_URL', 'jamiewatters.work')

    def parse_raw_report(self, content: str) -> Dict:
        """Parse raw report content into structured data.

        Args:
            content: Raw markdown report content

        Returns:
            Dict with project, date, deliverables, issues, next_steps
        """
        data = {
            'project': 'Unknown Project',
            'date': datetime.now().strftime('%Y-%m-%d'),
            'deliverables': [],
            'issues': [],
            'next_steps': []
        }

        # Extract project name
        project_match = re.search(r'#\s+([^\n]+)\s+Progress', content)
        if project_match:
            data['project'] = project_match.group(1).strip()

        # Extract date
        date_match = re.search(r'\*\*Date\*\*:\s+(\d{4}-\d{2}-\d{2})', content)
        if date_match:
            data['date'] = date_match.group(1)

        # Extract deliverables
        deliverables_section = re.search(
            r'##\s+Deliverables.*?(?=##|$)', content, re.DOTALL
        )
        if deliverables_section:
            items = re.findall(r'-\s+\*\*([^*]+)\*\*:([^\n]+)', deliverables_section.group(0))
            data['deliverables'] = [
                {'title': title.strip(), 'description': desc.strip()}
                for title, desc in items
            ]

        # Extract issues
        issues_section = re.search(
            r'##\s+Issues.*?(?=##|$)', content, re.DOTALL
        )
        if issues_section:
            # Look for issue entries with symptom, attempts, resolution
            issue_blocks = re.findall(
                r'###\s+([^\n]+).*?(?=###|##|$)',
                issues_section.group(0),
                re.DOTALL
            )
            for block in issue_blocks:
                data['issues'].append(block.strip())

        # Extract next steps
        next_section = re.search(
            r'##\s+Next.*?(?=##|$)', content, re.DOTALL
        )
        if next_section:
            items = re.findall(r'-\s+([^\n]+)', next_section.group(0))
            data['next_steps'] = [item.strip() for item in items if item.strip()]

        return data

    def generate_blog_prompt(self, data: Dict) -> str:
        """Generate LLM prompt for blog post creation.

        Args:
            data: Parsed report data

        Returns:
            Formatted prompt string
        """
        prompt = f"""Transform this daily progress report into an engaging blog post.

Project: {data['project']}
Date: {data['date']}

Deliverables:
{self._format_deliverables(data['deliverables'])}

Issues Resolved:
{self._format_issues(data['issues'])}

Next Steps:
{self._format_next_steps(data['next_steps'])}

Guidelines:
- Write in first-person, conversational tone
- Focus on wins and learning moments
- Keep it authentic and relatable (build-in-public style)
- Highlight technical decisions and why they matter
- Length: 400-600 words
- Include a brief intro and conclusion
- Use markdown formatting (## headers, **bold**, `code`)

Title format: "Building [Project]: [Key Achievement/Learning]"

Make it engaging and educational for other developers."""
        return prompt

    def generate_social_media_prompt(self, data: Dict) -> str:
        """Generate LLM prompt for social media posts.

        Args:
            data: Parsed report data

        Returns:
            Formatted prompt string requesting JSON output
        """
        # Generate progress link
        progress_link = f"https://{self.base_url}/progress/{data['date']}"

        prompt = f"""Create social media posts for this daily progress update.

Project: {data['project']}
Date: {data['date']}
Progress Link: {progress_link}

Deliverables:
{self._format_deliverables(data['deliverables'])}

Issues Resolved:
{self._format_issues(data['issues'])}

Next Steps:
{self._format_next_steps(data['next_steps'])}

Generate TWO posts in JSON format:

1. TWITTER/X POST:
   - 280 character HARD LIMIT (aim for 71-100 chars optimal)
   - Include progress link
   - 1-2 hashtags max from: #buildinpublic #solofounder #indiehacker #devlog
   - Strong hook + what was built + CTA pattern
   - Behind-the-scenes, build-in-public tone
   - Example: "Shipped [feature] today 🚀\\n\\nLearned [insight] the hard way.\\n\\nFull writeup: [link]\\n\\n#buildinpublic"

2. LINKEDIN POST:
   - 3,000 char limit, sweet spot 800-1000 chars
   - First 140 chars MUST be a compelling hook (shown before "see more")
   - Short one-line phrases preferred (easier to scan)
   - Include progress link
   - 0-3 hashtags only (LinkedIn dislikes hashtag spam)
   - End with an engagement question
   - Authentic, educational tone for developers/founders
   - Structure: Hook → What was built → Why it matters → Learning/insight → Question

Return ONLY valid JSON in this exact format:
{{
  "twitter": {{
    "content": "The complete tweet text with link and hashtags",
    "character_count": 145,
    "hashtags": ["buildinpublic", "solofounder"]
  }},
  "linkedin": {{
    "content": "The complete LinkedIn post with link and optional hashtags",
    "character_count": 876,
    "hook": "First 140 characters of the post",
    "hook_length": 98,
    "has_question": true
  }}
}}

IMPORTANT:
- Return ONLY the JSON object, no markdown formatting
- Ensure Twitter post is under 280 characters INCLUDING link and hashtags
- Ensure LinkedIn hook is under 140 characters
- Include actual URLs in the content
- Count characters accurately"""
        return prompt

    def _format_deliverables(self, deliverables: list) -> str:
        """Format deliverables list for prompt."""
        if not deliverables:
            return "None"
        return "\n".join(
            f"- {d['title']}: {d['description']}"
            for d in deliverables
        )

    def _format_issues(self, issues: list) -> str:
        """Format issues list for prompt."""
        if not issues:
            return "None"
        return "\n".join(f"- {issue}" for issue in issues)

    def _format_next_steps(self, next_steps: list) -> str:
        """Format next steps for prompt."""
        if not next_steps:
            return "None"
        return "\n".join(f"- {step}" for step in next_steps)

    def generate_blog_content(self, raw_content: str) -> str:
        """Generate blog post from raw report content.

        Args:
            raw_content: Raw markdown report

        Returns:
            AI-generated blog post content
        """
        data = self.parse_raw_report(raw_content)
        prompt = self.generate_blog_prompt(data)

        print("\n🤖 Generating blog post with AI...")

        try:
            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {
                        "role": "system",
                        "content": "You are a technical writer who creates engaging, "
                        "authentic blog posts about software development and building in public."
                    },
                    {"role": "user", "content": prompt}
                ],
                temperature=0.7,
                max_tokens=1500
            )

            blog_content = response.choices[0].message.content.strip()
            print("✅ Blog post generated successfully")
            return blog_content

        except Exception as e:
            raise Exception(f"Failed to generate blog content: {str(e)}")

    def generate_social_content(self, raw_content: str) -> Dict:
        """Generate social media posts from raw report content.

        Args:
            raw_content: Raw markdown report

        Returns:
            Dict with 'twitter' and 'linkedin' keys containing post data
        """
        data = self.parse_raw_report(raw_content)
        prompt = self.generate_social_media_prompt(data)

        print("\n🐦 Generating social media posts with AI...")

        try:
            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {
                        "role": "system",
                        "content": "You are a social media expert who creates engaging posts "
                        "for developers and founders. You understand platform-specific "
                        "best practices and character limits. Return only valid JSON."
                    },
                    {"role": "user", "content": prompt}
                ],
                temperature=0.7,
                max_tokens=1000
            )

            raw_response = response.choices[0].message.content.strip()

            # Clean up response - remove markdown code blocks if present
            json_content = raw_response
            if raw_response.startswith('```'):
                # Extract JSON from markdown code block
                json_match = re.search(r'```(?:json)?\n(.*?)```', raw_response, re.DOTALL)
                if json_match:
                    json_content = json_match.group(1).strip()

            # Parse JSON response
            social_data = json.loads(json_content)

            # Validate structure
            if 'twitter' not in social_data or 'linkedin' not in social_data:
                raise ValueError("Response missing required 'twitter' or 'linkedin' keys")

            # Validate Twitter character count
            twitter_count = social_data['twitter'].get('character_count', 0)
            if twitter_count > 280:
                print(f"⚠️  Warning: Twitter post is {twitter_count} chars (limit: 280)")

            # Validate LinkedIn hook length
            hook_length = social_data['linkedin'].get('hook_length', 0)
            if hook_length > 140:
                print(f"⚠️  Warning: LinkedIn hook is {hook_length} chars (limit: 140)")

            print("✅ Social media posts generated successfully")
            return social_data

        except json.JSONDecodeError as e:
            raise Exception(f"Failed to parse JSON response: {str(e)}\nRaw response: {raw_response}")
        except Exception as e:
            raise Exception(f"Failed to generate social content: {str(e)}")

    def format_blog_output(self, content: str, date: str, project: str) -> str:
        """Format blog content with metadata header.

        Args:
            content: AI-generated blog content
            date: Report date (YYYY-MM-DD)
            project: Project name

        Returns:
            Formatted blog post with metadata
        """
        # Parse date for human-readable format
        date_obj = datetime.strptime(date, '%Y-%m-%d')
        formatted_date = date_obj.strftime('%B %d, %Y')

        # Add metadata header
        output = f"""---
date: {date}
project: {project}
generated: {datetime.now().strftime('%Y-%m-%d %H:%M')}
---

{content}

---

*This post was AI-enhanced from daily progress logs using /dailyreport*
"""
        return output

    def format_twitter_output(self, data: Dict, date: str, project: str) -> str:
        """Format Twitter/X post with metadata.

        Args:
            data: Twitter post data from AI
            date: Report date (YYYY-MM-DD)
            project: Project name

        Returns:
            Formatted Twitter post file content
        """
        date_obj = datetime.strptime(date, '%Y-%m-%d')
        formatted_date = date_obj.strftime('%B %d, %Y')

        content = data.get('content', '')
        char_count = data.get('character_count', len(content))
        hashtags = data.get('hashtags', [])

        # Validate character count
        char_status = "✅" if char_count <= 280 else "⚠️"
        hashtag_status = "✅" if len(hashtags) <= 2 else "⚠️"

        # Check if link is included
        has_link = self.base_url in content or 'http' in content

        output = f"""# Twitter/X Post - {formatted_date}

**Project**: {project}
**Characters**: {char_count}/280

---

{content}

---

**Copy-paste ready** ⬆️

## Optimization Notes
- Character count: {char_count}/280 {char_status}
- Hashtags: {len(hashtags)}/2 {hashtag_status}
- Link included: {'Yes' if has_link else 'No'}

*Generated by /dailyreport on {datetime.now().strftime('%B %d, %Y at %H:%M')}*
"""
        return output

    def format_linkedin_output(self, data: Dict, date: str, project: str) -> str:
        """Format LinkedIn post with metadata.

        Args:
            data: LinkedIn post data from AI
            date: Report date (YYYY-MM-DD)
            project: Project name

        Returns:
            Formatted LinkedIn post file content
        """
        date_obj = datetime.strptime(date, '%Y-%m-%d')
        formatted_date = date_obj.strftime('%B %d, %Y')

        content = data.get('content', '')
        char_count = data.get('character_count', len(content))
        hook = data.get('hook', '')
        hook_length = data.get('hook_length', len(hook))
        has_question = data.get('has_question', False)

        # Validate lengths
        total_status = "✅" if char_count <= 3000 else "⚠️"
        hook_status = "✅" if hook_length <= 140 else "⚠️"

        # Check if link is included
        has_link = self.base_url in content or 'http' in content

        output = f"""# LinkedIn Post - {formatted_date}

**Project**: {project}
**Characters**: {char_count}/3000
**Hook Length**: {hook_length}/140 chars

---

{content}

---

**Copy-paste ready** ⬆️

## Optimization Notes
- Total characters: {char_count}/3000 {total_status}
- Hook length: {hook_length}/140 {hook_status}
- Engagement question: {'Yes' if has_question else 'No'}
- Link included: {'Yes' if has_link else 'No'}

*Generated by /dailyreport on {datetime.now().strftime('%B %d, %Y at %H:%M')}*
"""
        return output


def process_file(input_path: str) -> Tuple[str, Optional[str], Optional[str]]:
    """Process a daily report file and generate enhanced content.

    Args:
        input_path: Path to raw progress report

    Returns:
        Tuple of (blog_output_path, twitter_output_path, linkedin_output_path)
    """
    # Validate input file
    input_file = Path(input_path)
    if not input_file.exists():
        raise FileNotFoundError(f"Input file not found: {input_path}")

    # Read raw content
    print(f"📄 Reading: {input_file.name}")
    raw_content = input_file.read_text()

    # Initialize enhancer
    try:
        enhancer = DailyReportEnhancer()
    except ValueError as e:
        print(f"\n❌ {str(e)}")
        print("\nTo enable AI enhancement:")
        print("1. Get an OpenAI API key: https://platform.openai.com/api-keys")
        print("2. Set environment variable: export OPENAI_API_KEY='your-key'")
        print("3. Run the command again")
        return (str(input_file), None, None)

    # Parse to get metadata
    data = enhancer.parse_raw_report(raw_content)
    project = data['project']
    date = data['date']

    # Generate blog content
    try:
        blog_content = enhancer.generate_blog_content(raw_content)
        formatted_blog = enhancer.format_blog_output(blog_content, date, project)

        # Create blog output file
        blog_output = input_file.parent / f"{date}-blog.md"
        blog_output.write_text(formatted_blog)
        print(f"✅ Blog saved: {blog_output.name}")

    except Exception as e:
        print(f"❌ Blog generation failed: {str(e)}")
        return (str(input_file), None, None)

    # Generate social media content if enabled
    twitter_output_path = None
    linkedin_output_path = None

    if enhancer.enable_social:
        try:
            social_data = enhancer.generate_social_content(raw_content)

            # Create Twitter output file
            twitter_content = enhancer.format_twitter_output(
                social_data['twitter'], date, project
            )
            twitter_output = input_file.parent / f"{date}-twitter.md"
            twitter_output.write_text(twitter_content)
            twitter_output_path = str(twitter_output)
            print(f"✅ Twitter post saved: {twitter_output.name}")

            # Create LinkedIn output file
            linkedin_content = enhancer.format_linkedin_output(
                social_data['linkedin'], date, project
            )
            linkedin_output = input_file.parent / f"{date}-linkedin.md"
            linkedin_output.write_text(linkedin_content)
            linkedin_output_path = str(linkedin_output)
            print(f"✅ LinkedIn post saved: {linkedin_output.name}")

            # Show Twitter preview (it's short enough)
            print("\n" + "="*60)
            print("TWITTER PREVIEW (copy-paste ready):")
            print("="*60)
            print(social_data['twitter']['content'])
            print("="*60)

        except Exception as e:
            print(f"⚠️  Social media generation failed: {str(e)}")
            print("   Blog post was created successfully.")
    else:
        print("ℹ️  Social media generation disabled (DAILYREPORT_ENABLE_SOCIAL=false)")

    return (str(blog_output), twitter_output_path, linkedin_output_path)


def main():
    """Main entry point for the script."""
    if len(sys.argv) != 2:
        print("Usage: python enhance_dailyreport.py <input_file>")
        print("Example: python enhance_dailyreport.py progress/2025-11-29.md")
        sys.exit(1)

    input_path = sys.argv[1]

    print("\n" + "="*60)
    print("DAILY REPORT AI ENHANCEMENT")
    print("="*60)

    try:
        blog_path, twitter_path, linkedin_path = process_file(input_path)

        print("\n" + "="*60)
        print("GENERATION COMPLETE")
        print("="*60)
        print(f"\n📝 Blog post: {blog_path}")
        if twitter_path:
            print(f"🐦 Twitter post: {twitter_path}")
        if linkedin_path:
            print(f"💼 LinkedIn post: {linkedin_path}")
        print("\n✨ Ready to publish!\n")

    except Exception as e:
        print(f"\n❌ Error: {str(e)}\n")
        sys.exit(1)


if __name__ == "__main__":
    main()
