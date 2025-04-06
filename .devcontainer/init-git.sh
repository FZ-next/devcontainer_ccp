#!/bin/bash
set -e

# Set up git configuration for the devcontainer
# This script helps configure git with sensible defaults

echo "Configuring git for the devcontainer..."
echo "Note: This only affects git configuration within the container"

# Check if git is installed
if ! command -v git &> /dev/null; then
  echo "ERROR: Git is not installed"
  exit 1
fi

# Configure git defaults if not already set
# These are container-specific and won't affect the host's git config

# Configure default branch name to master for any new repositories
# Note: This won't affect existing repos
git config --global init.defaultBranch master
echo "Set default branch for new repos to 'master'"

# Configure git to use git-delta for diffs if available
if command -v delta &> /dev/null; then
  git config --global core.pager delta
  git config --global delta.navigate true
  git config --global delta.line-numbers true
  git config --global delta.side-by-side false
  echo "Configured git to use delta for improved diffs"
fi

# Set VSCode as the default editor for git
git config --global core.editor "code --wait"

# Set credential helper to cache credentials
git config --global credential.helper cache

# Set global git config for consistent line endings
git config --global core.autocrlf input

# Use colors in git output
git config --global color.ui auto

# Allow git to handle large files better
git config --global core.compression 9
git config --global http.postBuffer 157286400

# Set pull to rebase by default
git config --global pull.rebase true

# Print current git configuration
echo "Git configuration:"
git config --global --list

echo "Git configuration complete"