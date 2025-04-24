# Python Claude Code Development Environment

A pre-configured development environment using VS Code devcontainers, Poetry, and Claude Code. This template provides everything you need to start a new Python project with modern development practices built-in.

> **Note**: This container automatically sets up Poetry and installs dependencies when you open it in VS Code with the Dev Containers extension. It initialize git and pre-commit

For more information on the devcontainer see the DEVContainer_README.md file.

## Features

- Fully configured devcontainer with Python 3.11
- Poetry for dependency management
- Pre-configured tools:
  - Black for formatting (line length 79)
  - Mypy for strict type checking
  - Ruff for fast linting
  - Pre-commit hooks (automatically installed)
- Git configuration with sensible defaults
- Claude Code integration
- Comprehensive VS Code extensions
- Project and by that devcontainer image name is equal to the repository name

## Getting Started

1. Use this template to create a new repository
2. Clone your new repository
3. Open in VS Code with the Dev Containers extension installed
4. VS Code will prompt you to "Reopen in Container"
5. The container will automatically:
   - Set up Poetry with all dependencies
   - Configure Git with useful defaults
   - Install pre-commit hooks
6. Once inside the container, you can start developing immediately!

> **Note**: For detailed information about the devcontainer configuration, see [.devcontainer/README.md](.devcontainer/README.md)

## Usage

```bash
# Run tests
poetry run pytest

# Format code
poetry run black .

# Type check
poetry run mypy .

# Lint code
poetry run ruff check . --fix

# Run pre-commit hooks manually on all files
poetry run pre-commit run --all-files
```

### Pre-commit Hooks

This template includes pre-commit hooks that run automatically before each commit to ensure code quality:

- **black**: Formats Python code
- **ruff**: Lints Python code and fixes issues
- **mypy**: Checks Python type annotations
- **end-of-file-fixer**: Ensures files end with a newline
- **trailing-whitespace**: Trims trailing whitespace
- **check-yaml/json/toml**: Validates configuration files
- **detect-private-key**: Prevents committing private keys

## Structure

The project includes a sample package structure to help you get started:

```
src/                  # Source code directory
├── python_project/   # Main package (rename to your project name)
│   ├── __init__.py   # Package initialization
│   └── example.py    # Example module with typed functions and classes
└── __init__.py       # Source directory initialization

tests/                # Test directory
├── __init__.py       # Test initialization
└── test_example.py   # Example tests using pytest
```
