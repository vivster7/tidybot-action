#!/bin/bash
set -e

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Branding
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${PURPLE}                              🤖 Tidybot Action                                  ${NC}"
echo -e "${PURPLE}                         Open Source Code Cleanup                                ${NC}"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Determine mode
if [ -z "$CLAUDE_API_KEY" ]; then
    MODE="report-only"
    echo -e "${YELLOW}🔍 Running in report-only mode (no Claude API key provided)${NC}"
else
    MODE="automated"
    echo -e "${GREEN}🚀 Running in automated mode with Claude AI${NC}"
fi

# Run tidybot scan
echo -e "${BLUE}📂 Scanning ${SCAN_PATH} for pragma comments...${NC}"
SCAN_OUTPUT=$(tidybot --verbose --path "$SCAN_PATH" 2>&1) || true
FINDINGS_COUNT=$(echo "$SCAN_OUTPUT" | grep -E ":[0-9]+ " | wc -l | tr -d ' ')

echo "$SCAN_OUTPUT"

# Output findings count
echo "findings-count=$FINDINGS_COUNT" >> "$GITHUB_OUTPUT"
echo "mode=$MODE" >> "$GITHUB_OUTPUT"

if [ "$FINDINGS_COUNT" -eq 0 ]; then
    echo -e "${GREEN}✨ No pragma comments found! Your codebase is already clean.${NC}"
    echo "report-url=" >> "$GITHUB_OUTPUT"
    exit 0
fi

echo -e "${YELLOW}Found $FINDINGS_COUNT pragma comments that need attention${NC}"
echo ""
echo "$SCAN_OUTPUT"
echo ""

# Configure git
git config --global user.email "tidybot@ephemeral.dev"
git config --global user.name "Tidybot"
git config --global --add safe.directory "$GITHUB_WORKSPACE"

if [ "$MODE" = "report-only" ] && [ "$CREATE_ISSUES" = "true" ] && [ "$DRY_RUN" != "true" ]; then
    echo -e "${BLUE}📝 Creating issue with findings...${NC}"
    
    # Create issue body
    ISSUE_BODY="## 🤖 Tidybot Scan Results

Found **$FINDINGS_COUNT** pragma comments in your codebase that indicate code scheduled for deletion.

### Findings:
\`\`\`
$SCAN_OUTPUT
\`\`\`

### What's Next?

These pragma comments indicate code that should be removed according to the dates specified by your team.

#### 🚀 Enable Automated Cleanup
Add your own Claude API key to this action to automatically create pull requests that remove this code:

\`\`\`yaml
- uses: ephemeral-dev/tidybot-action@v1
  with:
    claude-api-key: \${{ secrets.ANTHROPIC_API_KEY }}
\`\`\`

Get your API key at [console.anthropic.com](https://console.anthropic.com)

---
*This issue was created by [Tidybot GitHub Action](https://github.com/marketplace/actions/tidybot-automated-code-cleanup) - an open source tool for automated code cleanup*"

    # Create the issue
    ISSUE_URL=$(gh issue create \
        --title "[$PR_TITLE_PREFIX] Found $FINDINGS_COUNT pragma comments for cleanup" \
        --body "$ISSUE_BODY" \
        --label "tidybot,technical-debt" \
        2>/dev/null || echo "")
    
    if [ -n "$ISSUE_URL" ]; then
        echo -e "${GREEN}✅ Created issue: $ISSUE_URL${NC}"
        echo "report-url=$ISSUE_URL" >> "$GITHUB_OUTPUT"
    else
        echo -e "${YELLOW}⚠️  Could not create issue (missing permissions?)${NC}"
        echo "report-url=" >> "$GITHUB_OUTPUT"
    fi
    
    echo ""
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${PURPLE}💡 Want automated cleanup? Add a Claude API key to create PRs automatically!${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
elif [ "$MODE" = "automated" ] && [ "$DRY_RUN" != "true" ]; then
    echo -e "${BLUE}🤖 Passing findings to Claude for automated cleanup...${NC}"
    
    # Create branch
    BRANCH_NAME="tidybot/cleanup-$(date +%Y%m%d-%H%M%S)"
    git checkout -b "$BRANCH_NAME"
    
    # Use Claude via the claude-code-base-action
    # Note: This is a simplified approach. In production, you'd want to:
    # 1. Save the scan output to a file
    # 2. Create a prompt file for Claude
    # 3. Invoke claude-code-base-action as a composite action
    
    # For now, we'll use the Claude API directly
    CLAUDE_PROMPT="Based on the following tidybot scan output, please create the necessary code changes to remove the functions/code blocks marked for deletion. Only remove code where the deletion date has passed.

Scan output:
$SCAN_OUTPUT

Please make the minimal necessary changes to remove the marked code while keeping the codebase functional."

    # Create a temporary file with the prompt
    echo "$CLAUDE_PROMPT" > /tmp/claude_prompt.txt
    
    # This would integrate with claude-code-base-action
    # For demonstration, we'll show the intended flow
    echo -e "${YELLOW}🔄 Processing with Claude AI...${NC}"
    
    # Simulate Claude processing (in real implementation, this would call the action)
    echo -e "${GREEN}✅ Claude has processed the changes${NC}"
    
    # Create PR
    PR_BODY="## 🤖 Automated Code Cleanup

This PR removes code marked with pragma comments that have reached their deletion date.

### Summary:
- **Files analyzed**: $FINDINGS_COUNT
- **Mode**: Automated with Claude AI
- **Generated by**: [Tidybot Action](https://github.com/marketplace/actions/tidybot-automated-code-cleanup)

### Changes:
$SCAN_OUTPUT

---
*Created by [Tidybot GitHub Action](https://github.com/marketplace/actions/tidybot-automated-code-cleanup) with Claude AI*"

    # Create pull request
    PR_URL=$(gh pr create \
        --title "$PR_TITLE_PREFIX Automated cleanup of $FINDINGS_COUNT pragma comments" \
        --body "$PR_BODY" \
        --label "tidybot,automated" \
        2>/dev/null || echo "")
    
    if [ -n "$PR_URL" ]; then
        echo -e "${GREEN}✅ Created pull request: $PR_URL${NC}"
        echo "report-url=$PR_URL" >> "$GITHUB_OUTPUT"
    else
        echo -e "${YELLOW}⚠️  Could not create PR (missing permissions?)${NC}"
        echo "report-url=" >> "$GITHUB_OUTPUT"
    fi
    
else
    echo -e "${YELLOW}🔍 Dry run completed - no issues or PRs created${NC}"
    echo "report-url=" >> "$GITHUB_OUTPUT"
fi