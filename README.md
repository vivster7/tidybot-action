# 🤖 Tidybot GitHub Action

[![GitHub Marketplace](https://img.shields.io/badge/Marketplace-Tidybot-purple)](https://github.com/marketplace/actions/tidybot-automated-code-cleanup)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A lightweight GitHub Action that finds and removes dead code based on pragma comments in your codebase. Keep your code clean without manual intervention.

## ✨ Features

- **🔍 Free Scanning**: Detect pragma comments and create issues - no API keys required
- **🤖 Bring Your Own AI**: Use your Claude API key for automated PR creation
- **📅 Date-Based Deletion**: Remove code when scheduled dates arrive
- **🎯 Zero Configuration**: Works out of the box with sensible defaults
- **⚡ Fast Execution**: Composite action runs directly on the runner
- **📊 Detailed Reports**: Get issues or PRs with comprehensive findings
- **🆓 100% Open Source**: MIT licensed and free to use

## 🚀 Quick Start

### Basic Usage (Report-Only Mode)

```yaml
name: Tidybot Scan
on:
  schedule:
    - cron: '0 0 * * *'  # Daily at midnight
  workflow_dispatch:

jobs:
  tidybot:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ephemeral-dev/tidybot-action@v1
```

This will scan your code and create an issue with any findings.

### Advanced Usage (Automated Mode)

```yaml
name: Tidybot Cleanup
on:
  schedule:
    - cron: '0 0 * * *'  # Daily at midnight
  workflow_dispatch:

jobs:
  tidybot:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ephemeral-dev/tidybot-action@v1
        with:
          claude-api-key: ${{ secrets.ANTHROPIC_API_KEY }}
```

This will automatically create PRs to remove code marked for deletion using your Claude API key.

## 📝 Pragma Comment Syntax

Tidybot recognizes several pragma comment patterns:

```javascript
// tidybot: delete this function on 2024-12-31
function deprecatedFeature() {
  // This code will be automatically removed after Dec 31, 2024
}

// TODO(tidybot): Delete this code on Jan 1, 2025
class LegacyHandler {
  // Scheduled for removal
}
```

## ⚙️ Configuration

| Input | Description | Default | Required |
|-------|-------------|---------|----------|
| `claude-api-key` | Your Anthropic API key for automated PR creation | - | No |
| `path` | Path to scan for pragma comments | `.` | No |
| `create-issues` | Create GitHub issues in report-only mode | `true` | No |
| `pr-title-prefix` | Prefix for PR titles | `[tidybot]` | No |
| `dry-run` | Run without creating issues/PRs | `false` | No |

## 📊 Outputs

| Output | Description |
|--------|-------------|
| `findings-count` | Number of pragma comments found |
| `report-url` | URL to the created issue or PR |
| `mode` | Mode the action ran in (`report-only` or `automated`) |

## 🎯 Use Cases

### 1. Technical Debt Management
```yaml
# Scan weekly and create issues for tracking
- uses: ephemeral-dev/tidybot-action@v1
  with:
    create-issues: true
```

### 2. Automated Cleanup Pipeline
```yaml
# Fully automated with Claude AI
- uses: ephemeral-dev/tidybot-action@v1
  with:
    claude-api-key: ${{ secrets.ANTHROPIC_API_KEY }}
    pr-title-prefix: '[AutoCleanup]'
```

### 3. Dry Run for Testing
```yaml
# Test what would be found without any side effects
- uses: ephemeral-dev/tidybot-action@v1
  with:
    dry-run: true
```

## 🔄 Migration from Manual Process

If you're currently using pragma comments but cleaning up manually:

1. **Start with report-only mode** to understand what will be affected
2. **Review the generated issues** to ensure accuracy
3. **Add Claude API key** when ready for automation
4. **Monitor the PRs** initially to build confidence

## 🛠️ How It Works

1. **Scan**: Tidybot scans your codebase for pragma comments with deletion dates
2. **Report**: Creates GitHub issues listing all findings (report-only mode)
3. **Automate**: With a Claude API key, automatically creates PRs to remove expired code
4. **Review**: You review and merge the PRs when ready

## 🧪 Testing

### Local Testing

Test the action locally before using it in your workflows:

```bash
# Clone the repository
git clone https://github.com/ephemeral-dev/tidybot-action.git
cd tidybot-action

# Run local tests
bash test-local.sh
```

### Test Repository

We provide a test repository with sample pragma comments:

```bash
# Clone the test repository
git clone https://github.com/ephemeral-dev/tidybot-action-test.git
cd tidybot-action-test

# View test files with pragma comments
find . -name "*.js" -o -name "*.py" -o -name "*.go" | xargs grep -E "(tidybot:|TODO\(tidybot\))"
```

### Integration Testing

To test in your own repository:

1. Add some test pragma comments:
   ```javascript
   // tidybot: delete this function on 2024-01-01
   function testFunction() { }
   ```

2. Create a test workflow (`.github/workflows/test-tidybot.yml`):
   ```yaml
   name: Test Tidybot
   on: workflow_dispatch
   
   jobs:
     test:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - uses: ephemeral-dev/tidybot-action@v1
           with:
             dry-run: true
   ```

3. Run the workflow manually from the Actions tab

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙋 Support

- **Issues**: [GitHub Issues](https://github.com/ephemeral-dev/tidybot-action/issues)
- **Discussions**: [GitHub Discussions](https://github.com/ephemeral-dev/tidybot-action/discussions)

---

<p align="center">
  Made with ❤️ by the Tidybot team
</p>