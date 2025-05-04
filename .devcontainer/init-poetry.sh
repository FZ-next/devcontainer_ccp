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

# If a virtual environment already exists and is owned by root, fix it
if [ -d "/workspace/.venv" ]; then
  echo "Checking virtual environment ownership..."
  venv_owner=$(stat -c '%U' /workspace/.venv)
  if [ "$venv_owner" != "$(whoami)" ]; then
    echo "Fixing virtual environment ownership..."
    sudo chown -R $(whoami):$(whoami) /workspace/.venv
  fi
fi

# Update poetry lock file
echo "Updating poetry lock file..."
cd /workspace && poetry lock

# Clean up any existing virtual environment if it's causing issues
if [ -d "/workspace/.venv" ]; then
  echo "Checking virtual environment..."
  if ! /workspace/.venv/bin/python -c "print('Venv test')" &>/dev/null; then
    echo "Virtual environment not working properly, removing and recreating..."
    rm -rf /workspace/.venv
  fi
fi

# Install dependencies
echo "Installing dependencies..."
cd /workspace && poetry install --no-root

# Final ownership check
if [ -d "/workspace/.venv" ]; then
  venv_owner=$(stat -c '%U' /workspace/.venv)
  if [ "$venv_owner" != "$(whoami)" ]; then
    echo "Fixing virtual environment ownership after installation..."
    sudo chown -R $(whoami):$(whoami) /workspace/.venv
  fi

  # Make all binaries in venv executable
  echo "Ensuring all virtual environment binaries are executable..."
  find /workspace/.venv/bin -type f -exec chmod +x {} \;
fi

# Configure shell for Python automatic activation
for shell_rc in ~/.bashrc ~/.zshrc; do
  if [ -f "$shell_rc" ]; then
    # Automatically activate venv when in workspace directory
    if ! grep -q "WORKSPACE_VENV_AUTO_ACTIVATE" "$shell_rc"; then
      echo "Adding auto-activation of Python venv to $shell_rc..."
      cat >> "$shell_rc" << 'EOF'

# Automatically activate Python virtual environment when in workspace directory
# WORKSPACE_VENV_AUTO_ACTIVATE marker
function cd() {
  builtin cd "$@" || return
  if [[ "$PWD" == "/workspace"* ]]; then
    if [ -d "/workspace/.venv" ] && [ -f "/workspace/.venv/bin/activate" ] && [ -z "$VIRTUAL_ENV" ]; then
      echo "Activating Python virtual environment..."
      source /workspace/.venv/bin/activate
    fi
  elif [ -n "$VIRTUAL_ENV" ] && [[ "$VIRTUAL_ENV" == "/workspace/.venv"* ]]; then
    echo "Deactivating Python virtual environment..."
    deactivate
  fi
}

# Initial activation if starting in workspace
if [[ "$PWD" == "/workspace"* ]] && [ -d "/workspace/.venv" ] && [ -f "/workspace/.venv/bin/activate" ] && [ -z "$VIRTUAL_ENV" ]; then
  echo "Activating Python virtual environment..."
  source /workspace/.venv/bin/activate
fi
EOF
    fi
  fi
done

# Activate the venv right now if we're in the workspace
if [[ "$PWD" == "/workspace"* ]] && [ -d "/workspace/.venv" ] && [ -f "/workspace/.venv/bin/activate" ] && [ -z "$VIRTUAL_ENV" ]; then
  echo "Activating Python virtual environment now..."
  source /workspace/.venv/bin/activate
fi

echo "Python environment setup complete!"
