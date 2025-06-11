#!/bin/bash
set -e

echo "🧪 Testing tidybot GitHub Action locally"
echo "======================================="

# Set up test environment
export SCAN_PATH="../tidybot-action-test"
export CREATE_ISSUES="false"
export DRY_RUN="true"
export GITHUB_WORKSPACE="../tidybot-action-test"
export GITHUB_OUTPUT="/tmp/github_output.txt"
export GITHUB_TOKEN="fake-token-for-testing"

# Add tidybot to PATH (for local testing)
export PATH="$(pwd):$PATH"

# Create empty output file
> "$GITHUB_OUTPUT"

# Test 1: Report-only mode
echo ""
echo "Test 1: Report-only mode"
echo "-------------------------"
unset CLAUDE_API_KEY
bash entrypoint.sh

echo ""
echo "Test 2: Automated mode (dry run)"
echo "---------------------------------"
export CLAUDE_API_KEY="test-key-12345"
bash entrypoint.sh

echo ""
echo "✅ All tests completed!"
echo ""
echo "GitHub Action outputs:"
cat "$GITHUB_OUTPUT"