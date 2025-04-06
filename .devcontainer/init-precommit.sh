#!/bin/bash
set -e

# Set up pre-commit hooks for the Python project
# This script activates pre-commit hooks (pre-commit is installed via Poetry)

echo "Setting up pre-commit hooks..."

# Check if we're in a git repository
if [ ! -d ".git" ]; then
  echo "Notice: .git directory not found. Pre-commit will not be activated yet."
  echo "This is normal if you're using this as a template repository."
  exit 0
fi

# Check if pre-commit config exists
if [ ! -f ".pre-commit-config.yaml" ]; then
  echo "Notice: .pre-commit-config.yaml not found. Pre-commit will not be activated."
  exit 0
fi

# Install the pre-commit hooks
echo "Installing pre-commit hooks..."
poetry run pre-commit install

# Install the pre-commit hook for commit messages
poetry run pre-commit install --hook-type commit-msg

echo "Pre-commit hooks installed successfully."
echo "They will run automatically on git commit."
echo "You can also run them manually with: poetry run pre-commit run --all-files"