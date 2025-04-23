# Python Claude Code Development Environment

A pre-configured development environment using VS Code devcontainers, Poetry, and Claude Code. This template provides everything you need to start a new Python project with modern development practices built-in.

> **Note**: This container automatically sets up Poetry and installs dependencies when you open it in VS Code with the Dev Containers extension.

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
# Install dependencies
poetry install

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
├── workspace/   # Main package (rename to your project name)
│   ├── __init__.py   # Package initialization
│   └── example.py    # Example module with typed functions and classes
└── __init__.py       # Source directory initialization

tests/                # Test directory
├── __init__.py       # Test initialization
└── test_example.py   # Example tests using pytest
```

When using this template:

### Option 1: Use the automated renaming script
```bash
# Replace "my_awesome_project" with your desired project name
python .devcontainer/rename_project.py my_awesome_project
```

### Option 2: Manually rename the project
1. Rename the `workspace` directory to your project name
2. Update the package name in `pyproject.toml`
3. Adjust imports in test files to match your new package name

The devcontainer will automatically set up your environment with all tools configured in pyproject.toml.
