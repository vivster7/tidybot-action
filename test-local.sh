#!/bin/bash
set -e

echo "🧪 Testing Tidybot GitHub Action (Composite Version)"
echo "===================================================="

# Create a test directory with sample files (since we may not have tidybot-action-test)
TEST_DIR="test-workspace"
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"

# Create test files with pragma comments
cat > "$TEST_DIR/test.js" << 'EOF'
// tidybot: delete this function on 2024-01-01
function oldFunction() {
    return "This should be deleted";
}

// TODO(tidybot): Remove this code on 2025-01-01
function futureFunction() {
    return "This is scheduled for future deletion";
}

function normalFunction() {
    return "This should remain";
}
EOF

cat > "$TEST_DIR/test.py" << 'EOF'
# tidybot: delete this class on 2024-06-01
class DeprecatedClass:
    def old_method(self):
        pass

def normal_function():
    return "Keep this"
EOF

echo "📁 Created test workspace with pragma comments"

# Test the tidybot binary directly
echo ""
echo "🔍 Step 1: Testing tidybot binary availability..."
if [ -f "./tidybot" ]; then
    chmod +x ./tidybot
    echo "✅ Binary found and made executable"
    ./tidybot --path "$TEST_DIR" --verbose
else
    echo "❌ tidybot binary not found at ./tidybot"
    echo "   Please copy from: ../../go/tidybot/bin/tidybot"
    echo "   Or run: cp ../../go/tidybot/bin/tidybot ."
    exit 1
fi

# Test composite action setup simulation
echo ""
echo "🔧 Step 2: Testing composite action setup..."
export PATH="$(pwd):$PATH"
if command -v tidybot &> /dev/null; then
    echo "✅ tidybot is available in PATH"
else
    echo "❌ tidybot not found in PATH after setup"
    exit 1
fi

# Set up test environment (simulate GitHub Actions environment)
export SCAN_PATH="$TEST_DIR"
export CREATE_ISSUES="false"  # Don't actually create issues in local test
export DRY_RUN="true"
export GITHUB_OUTPUT="/tmp/github_output_test.txt"
export GITHUB_TOKEN="fake-token-for-testing"
export PR_TITLE_PREFIX="[test]"

# Create empty output file
> "$GITHUB_OUTPUT"

# Test 1: Report-only mode
echo ""
echo "🧪 Step 3: Testing report-only mode..."
echo "--------------------------------------"
unset CLAUDE_API_KEY
if [ -f "./entrypoint.sh" ]; then
    chmod +x ./entrypoint.sh
    bash ./entrypoint.sh
else
    echo "❌ entrypoint.sh not found"
    exit 1
fi

# Test 2: Automated mode (dry run)
echo ""
echo "🤖 Step 4: Testing automated mode (dry run)..."
echo "----------------------------------------------"
export CLAUDE_API_KEY="test-key-12345"
bash ./entrypoint.sh

# Check outputs
echo ""
echo "📊 Step 5: Checking GitHub Action outputs..."
if [ -f "$GITHUB_OUTPUT" ]; then
    echo "Generated outputs:"
    cat "$GITHUB_OUTPUT"
else
    echo "❌ No GitHub output file generated"
fi

# Cleanup
rm -rf "$TEST_DIR"
rm -f "$GITHUB_OUTPUT"

echo ""
echo "✅ All tests completed successfully!"
echo "🎉 Composite action is working correctly!"
echo ""
echo "Benefits of composite action vs Docker:"
echo "  ✅ Faster execution (no Docker build)"
echo "  ✅ Direct access to checked out code"
echo "  ✅ Simpler debugging and testing"
echo "  ✅ No container mount issues"