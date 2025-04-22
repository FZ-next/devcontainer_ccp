# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands
- Install: `poetry install`
- Run tests: `poetry run pytest`
- Run single test: `poetry run pytest tests/path_to_test.py::test_name`
- Format code: `poetry run black .`
- Type check: `poetry run mypy .`
- Lint: `poetry run ruff check . --fix`
- Pre-commit: `poetry run pre-commit run --all-files`

## Git & Pre-commit
- Git is configured automatically by the devcontainer
- Pre-commit hooks are installed automatically on container startup
- Hooks will run on each commit to ensure code quality
- Use `poetry run pre-commit run --all-files` to run hooks manually on all files

## Project Structure
- Source code is in the `src/` directory
- Main package is in `src/python_project/` (rename when starting a project)
- Tests are in `tests/` directory matching the structure of the source

## Code Style Guidelines
- **Formatting**: Black with 79 character line length
- **Linting**: Ruff for linting with automatic fixes
- **Types**: Use strict typing for all functions and classes
  - All function parameters and return values must have type annotations
  - Use `Optional`, `List`, `Dict`, etc. from `typing` module
- **Imports**: Organize in three groups with a blank line between each:
  1. Standard library imports
  2. Third-party imports
  3. Local application imports
- **Naming**:
  - `snake_case` for variables, functions, and modules
  - `PascalCase` for classes
  - `UPPER_CASE` for constants
- **Documentation**: Google-style docstrings for all functions and classes
- **Error Handling**: Use typed exceptions with descriptive messages
