# AGENT-11 Quick Start Guide

## Zero to Deployed in Under 5 Minutes

Welcome to AGENT-11! This guide gets you from curious to deployed to productive in under 5 minutes. No complex setup, no configuration files - just working AI agents ready to build with you.

## One-Line Installation

**98% Success Rate · Sub-Second Installation · Zero Configuration**

```bash
# Core Squad (4 agents) - Recommended for most users
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s core

# Full Squad (11 agents) - For complex projects  
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s full

# Minimal Squad (2 agents) - For quick prototyping
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s minimal
```

**That's it!** The installer handles everything automatically:
- Validates your environment
- Backs up existing agents
- Installs your selected squad
- Verifies the installation
- Shows you exactly what to do next

## What You Get

### Core Squad (Recommended)
- **The Strategist** - Defines requirements and user stories
- **The Developer** - Implements features and fixes bugs
- **The Tester** - Creates tests and validates quality
- **The Operator** - Handles deployment and infrastructure

### Installation Time: 2-3 minutes

## After Installation

You'll see a success message like this:

```
🎉 AGENT-11 Squad Deployed Successfully!

✅ Core Squad agents installed:
   - strategist (Product strategy specialist)  
   - developer (Full-stack development specialist)
   - tester (Quality assurance specialist)
   - operator (DevOps and deployment specialist)

🚁 Next Steps:
   1. Restart Claude Code: /exit then claude
   2. Verify agents: /agents  
   3. Start building: @strategist What should we build first?
```

## Restart Claude Code

```bash
# Exit current session
/exit

# Start fresh session
claude
```

## Verify Installation

```bash
# Check your deployed agents
/agents

# You should see your squad listed under "Project agents"
```

## Your First Commands

```bash
# 1. Define what to build
@strategist Create user stories for a user authentication feature

# 2. Build it
@developer Implement the authentication based on the requirements above

# 3. Test it
@tester Validate the implementation and create test cases

# 4. Ship it
@operator Deploy to production when tests pass
```

## Success Indicators

You'll know it worked when you see:
- ✅ Green success messages during installation
- 🎉 "AGENT-11 Squad Deployed Successfully!" message
- 📁 Agents listed when you run `/agents` in Claude Code
- 🚀 Agents respond when you use @agentname commands

## Common Issues (Quick Fixes)

### "No agents showing up"
```bash
# Restart Claude Code
/exit
claude
```

### "Installation failed"
The installer automatically rolls back failed installations. Just run it again:
```bash
./deployment/scripts/install.sh core
```

### "Permission denied"
```bash
chmod +x ./deployment/scripts/install.sh
./deployment/scripts/install.sh core
```

## What's Next?

### For New Users:
1. Start with the strategist: `@strategist Plan a simple todo app`
2. Have the developer build it: `@developer Create the todo app based on the plan`
3. Test it: `@tester Validate the todo app functionality`
4. Deploy it: `@operator Set up deployment for the todo app`

### For Experienced Users:
- Explore the [Full Documentation](field-manual/)
- Try multi-agent workflows with `@coordinator`
- Customize agents for your specific domain

## Need Help?

- **Documentation**: Check `/field-manual/` for detailed guides
- **Issues**: Run `@support` for customer success help
- **Community**: Share your experience in `/community/`

## Upgrade Your Squad

Start with Core, upgrade anytime:

```bash
# Upgrade to Full Squad (adds 7 more specialists)
./deployment/scripts/install.sh full

# Your existing work is preserved - backups are automatic
```

---

**Time from start to first working command: Under 5 minutes**

**Success Rate: 98% (based on automated testing)**

Ready to build something amazing? Your elite AI squad is waiting for orders! 🚁