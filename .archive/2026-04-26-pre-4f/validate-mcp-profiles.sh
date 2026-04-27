#!/bin/bash
# validate-mcp-profiles.sh - Validate MCP profile installation

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Validating MCP Profile System...${NC}"
echo ""

# Check profile directory exists
if [ ! -d ".mcp-profiles" ]; then
  echo -e "${RED}❌ .mcp-profiles/ directory not found${NC}"
  echo "   Run: ./project/deployment/scripts/install.sh"
  exit 1
fi
echo -e "${GREEN}✅ Profile directory exists${NC}"

# Check all 7 profiles exist
PROFILES=("core" "testing" "database-staging" "database-production" "payments" "deployment" "fullstack")
MISSING=0

for profile in "${PROFILES[@]}"; do
  if [ ! -f ".mcp-profiles/${profile}.json" ]; then
    echo -e "${RED}❌ Missing profile: ${profile}.json${NC}"
    MISSING=$((MISSING + 1))
  fi
done

if [ $MISSING -eq 0 ]; then
  echo -e "${GREEN}✅ All 7 profiles present${NC}"
else
  echo -e "${RED}❌ Missing $MISSING profiles${NC}"
  exit 1
fi

# Validate JSON syntax for each profile
echo ""
echo -e "${BLUE}🔍 Validating JSON syntax...${NC}"

for profile in "${PROFILES[@]}"; do
  if command -v python3 &> /dev/null; then
    if python3 -m json.tool ".mcp-profiles/${profile}.json" > /dev/null 2>&1; then
      echo -e "${GREEN}✅ ${profile}.json is valid JSON${NC}"
    else
      echo -e "${RED}❌ ${profile}.json has invalid JSON${NC}"
      exit 1
    fi
  elif command -v jq &> /dev/null; then
    if jq empty ".mcp-profiles/${profile}.json" > /dev/null 2>&1; then
      echo -e "${GREEN}✅ ${profile}.json is valid JSON${NC}"
    else
      echo -e "${RED}❌ ${profile}.json has invalid JSON${NC}"
      exit 1
    fi
  else
    echo -e "${YELLOW}⚠️  Cannot validate JSON (python3 or jq not found)${NC}"
    break
  fi
done

# Check if .env.mcp.template exists
echo ""
if [ -f ".env.mcp.template" ]; then
  echo -e "${GREEN}✅ .env.mcp.template exists${NC}"
else
  echo -e "${YELLOW}⚠️  .env.mcp.template not found (optional)${NC}"
fi

# Check if MCP documentation exists
if [ -f "docs/MCP-GUIDE.md" ]; then
  echo -e "${GREEN}✅ MCP documentation installed${NC}"
else
  echo -e "${YELLOW}⚠️  MCP documentation not found (optional)${NC}"
fi

# Check current profile status
echo ""
if [ -L ".mcp.json" ]; then
  CURRENT=$(readlink .mcp.json)
  echo -e "${GREEN}✅ Active profile: $CURRENT${NC}"
else
  echo -e "${BLUE}ℹ️  No active profile (symlink not created)${NC}"
  echo "   Choose profile: ln -sf .mcp-profiles/core.json .mcp.json"
fi

echo ""
echo -e "${GREEN}✅ MCP Profile System validation complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Setup MCP servers: ./project/deployment/scripts/mcp-setup.sh"
echo "  2. Configure API keys: cp .env.mcp.template .env.mcp && nano .env.mcp"
echo "  3. Choose profile: ln -sf .mcp-profiles/core.json .mcp.json"
echo "  4. Restart Claude Code"
echo ""
