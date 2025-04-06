#!/bin/bash
set -e

# Create directories if needed
mkdir -p ~/.zfunc

# Ensure poetry is in PATH or add symlink
if ! command -v poetry &> /dev/null; then
  echo "Poetry command not found in PATH, creating symlink..."
  if [ -f "/root/.local/bin/poetry" ]; then
    sudo ln -sf /root/.local/bin/poetry /usr/local/bin/poetry
  else
    echo "Cannot find poetry installation, attempting to fix..."
    # Try to reinstall poetry for current user
    curl -sSL https://install.python-poetry.org | python3 -

    if [ -f "$HOME/.local/bin/poetry" ]; then
      # If installed to user's .local/bin
      echo "Poetry installed to $HOME/.local/bin/poetry"
    else
      echo "ERROR: Poetry installation failed"
      exit 1
    fi
  fi
fi

# Add poetry to PATH in shell configs
for shell_rc in ~/.bashrc ~/.zshrc; do
  if [ -f "$shell_rc" ]; then
    # Add PATH if not already there
    if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$shell_rc"; then
      echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$shell_rc"
    fi
  fi
done

# Check if poetry is working
if ! poetry --version; then
  echo "ERROR: Poetry installation not working properly"
  exit 1
fi

# Enable tab completion
poetry completions bash > ~/.bash_completion || echo "Warning: Failed to create bash completions"
poetry completions zsh > ~/.zfunc/_poetry || echo "Warning: Failed to create zsh completions"

# Add to zshrc if using zsh
if [ -f ~/.zshrc ]; then
  grep -q "fpath+=~/.zfunc" ~/.zshrc || echo "fpath+=~/.zfunc" >> ~/.zshrc
  grep -q "autoload -Uz compinit && compinit" ~/.zshrc || echo "autoload -Uz compinit && compinit" >> ~/.zshrc
fi

# Configure poetry
poetry config virtualenvs.in-project true

# Ensure we have permissions in workspace directory
if [ ! -w "/workspace" ]; then
  echo "Warning: Don't have write permissions in /workspace"
  sudo chown -R $(whoami) /workspace
fi

# Update poetry lock file
echo "Updating poetry lock file..."
cd /workspace && poetry lock

# Install dependencies 
echo "Installing dependencies..."
cd /workspace && poetry install --no-root