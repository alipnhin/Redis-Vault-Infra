# Contributing to Redis-Vault-Infra

Thank you for your interest in contributing to Redis-Vault-Infra! This document provides guidelines and instructions for contributing.

## Code of Conduct

By participating in this project, you agree to abide by our Code of Conduct:
- Be respectful
- Be helpful
- Be patient
- Be professional

## How to Contribute

### Reporting Bugs

1. Check if the bug has already been reported
2. Use the bug report template
3. Include detailed steps to reproduce
4. Include expected and actual behavior
5. Include relevant logs and screenshots

### Suggesting Features

1. Check if the feature has already been suggested
2. Use the feature request template
3. Explain the problem you're trying to solve
4. Describe your proposed solution
5. Include any relevant examples

### Pull Requests

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Write tests
5. Update documentation
6. Create a pull request

## Development Setup

### Prerequisites

- Git
- Docker
- Docker Compose
- Node.js (v14+)
- npm or yarn
- kubectl (for Kubernetes examples)

### Local Development

1. Fork and clone the repository:
```bash
git clone https://github.com/your-username/Redis-Vault-Infra.git
cd Redis-Vault-Infra
```

2. Install dependencies:
```bash
npm install
```

3. Set up pre-commit hooks:
```bash
npm run prepare
```

4. Start development environment:
```bash
docker-compose up -d
```

## Code Style

### General Guidelines

- Follow existing code style
- Use meaningful variable names
- Write clear comments
- Keep functions small and focused
- Write tests for new features

### Shell Scripts

- Use shellcheck
- Follow shell style guide
- Add proper error handling
- Include usage documentation

### YAML Files

- Use consistent indentation
- Follow Kubernetes best practices
- Include comments for complex configurations
- Validate with yamllint

### Documentation

- Use Markdown format
- Follow existing documentation style
- Include examples
- Keep documentation up to date

## Testing

### Running Tests

```bash
# Run all tests
npm test

# Run specific test
npm test -- --grep "test name"
```

### Writing Tests

- Write tests for new features
- Update tests for modified features
- Ensure good test coverage
- Follow testing best practices

## Commit Messages

Follow the Conventional Commits specification:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types:
- feat: New feature
- fix: Bug fix
- docs: Documentation
- style: Formatting
- refactor: Code restructuring
- test: Adding tests
- chore: Maintenance

## Review Process

1. All pull requests require review
2. Address review comments
3. Keep pull requests focused
4. Update documentation
5. Ensure tests pass

## Release Process

1. Update version in package.json
2. Update CHANGELOG.md
3. Create release branch
4. Create pull request
5. Review and merge
6. Create release tag

## Questions?

Feel free to:
- Open an issue
- Contact maintainers
- Join discussions
- Check documentation 