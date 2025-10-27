# Contributing to Azure PIM Solution

Thank you for your interest in contributing to the Azure PIM Solution! This document provides guidelines and instructions for contributing.

## Code of Conduct

This project adheres to a Code of Conduct that all contributors are expected to follow. Please be respectful and constructive in all interactions.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the issue list as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

- Clear and descriptive title
- Steps to reproduce the issue
- Expected behavior
- Actual behavior
- Screenshots (if applicable)
- Environment details (OS, PowerShell version, Azure CLI version)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

- A clear and descriptive title
- Detailed description of the proposed enhancement
- Use cases for the enhancement
- Potential implementation approach (if you have ideas)

### Pull Requests

1. Fork the repo and create your branch from `main`
2. If you've added code, add tests if applicable
3. Ensure your code follows existing style conventions
4. Update documentation as needed
5. Make sure your changes work and don't break existing functionality
6. Commit your changes (see [Commit Guidelines](#commit-guidelines))
7. Push to your fork
8. Open a Pull Request

## Development Setup

### Prerequisites

- PowerShell 7.0+
- Azure PowerShell modules
- Microsoft Graph PowerShell modules
- Git

### Getting Started

```powershell
# Clone your fork
git clone https://github.com/YOUR-USERNAME/azure-pim-solution.git
cd英美 azure-pim-solution

# Add upstream remote
git remote add upstream https://github.com/original-username/azure-pim-solution.git

# Create a new branch
git checkout -b feature/your-feature-name
```

## Commit Guidelines

We follow conventional commit format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

Example:
```
feat(scripts): add Key Vault integration support

Add ability to use existing Key Vault instances instead of
always creating new ones. Includes detection logic and
safe secret management.

Closes #123
```

## Code Style

### PowerShell

- Use PowerShell 7.0+ syntax
- Follow PSScriptAnalyzer guidelines
- Use approved verbs
- Add comment-based help to all scripts
- Use meaningful variable names
- Handle errors appropriately

### Documentation

- Use clear, non-technical language where possible
- Follow the existing documentation style
- Include examples
- Add tables and diagrams where helpful

## Testing

Before submitting a PR:

1. Test your changes in a development environment
2. Run existing tests if available
3. Verify documentation builds correctly
4. Ensure no breaking changes (unless intentional)

## Documentation

Documentation is as important as code. When adding new features:

1. Update relevant documentation files
2. Add examples if applicable
3. Update the README if adding major features
4. Add/update troubleshooting sections

## Questions?

Feel free to open an issue for any questions about contributing.

Thank you for contributing! 🎉

