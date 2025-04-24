# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Environment
- This project runs in a devcontainer environment
- Python version: 3.11 or above
- Package management: Poetry
- Quality tools: pre-commit hooks run automatically on commit

## Common Commands
- Install dependencies: `poetry install`
- Run tests: `poetry run pytest`
- Run specific test: `poetry run pytest tests/path_to_test.py::test_name`
- Format code: `poetry run black .`
- Type check: `poetry run mypy .`
- Lint: `poetry run ruff check . --fix`
- Run all pre-commit hooks: `poetry run pre-commit run --all-files`
- Add dependency: `poetry add package_name`
- Add dev dependency: `poetry add --group dev package_name`
- Enter virtual environment: `poetry shell`

## Project Structure
- Source code: Located in `src/` directory
- Tests: Located in `tests/` directory mirroring the source structure
- Configuration: Located in `pyproject.toml` and `.pre-commit-config.yaml`

## Code Style Guidelines
- **Formatting**: Black with line length defined in pyproject.toml
- **Linting**: Ruff for linting with configured rules
- **Types**: Strict typing required
  - All function parameters and return values must have type annotations
  - Use types from `typing` module (`List`, `Dict`, `Optional`, etc.)
  - For Python 3.9+, use built-in types (`list`, `dict`, etc.) where possible
- **Imports**: Organized in these groups with blank lines between:
  1. Standard library imports
  2. Third-party imports
  3. Local application imports
- **Naming Conventions**:
  - `snake_case` for variables, functions, and modules
  - `PascalCase` for classes
  - `UPPER_CASE` for constants
- **Documentation**: Google-style docstrings for all public functions and classes
- **Error Handling**: Use typed exceptions with descriptive error messages

## Testing Guidelines
- Use pytest for all tests
- Test files should be named `test_*.py`
- Test functions should be named `test_*`
- Write unit tests for all public functions and methods
- Aim for high test coverage (>= 80%)
- Use fixtures for test setup and teardown
- Use parametrized tests for testing multiple scenarios
- Mock external dependencies when appropriate
- Test both success and error cases
- Run tests regularly during development

## Python Best Practices
- Follow the Zen of Python (`import this`)
- Use context managers (`with` statements) for resource management
- Prefer explicit over implicit code
- Write small, focused functions with a single responsibility
- Use list/dict/set comprehensions for concise data transformations
- Utilize generators for memory-efficient iteration
- Handle exceptions at the appropriate level
- Prefer composition over inheritance when possible
- Use dataclasses or Pydantic models for structured data
- Follow the principle of least privilege for security
- Make use of Python's standard library before adding dependencies
- Avoid global variables and mutable default arguments
- Use `pathlib` instead of `os.path` for file operations
- Utilize f-strings for string formatting
- Implement proper logging instead of print statements
- Consider compatibility with different Python versions if needed

## Git Workflow
- Create feature branches from main branch
- Keep commits focused and atomic
- Write descriptive commit messages
- Pre-commit hooks run automatically to enforce code quality
