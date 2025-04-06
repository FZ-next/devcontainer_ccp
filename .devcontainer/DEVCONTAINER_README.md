# Dev Container Documentation

This directory contains the configuration for the VS Code Development Container used in this project. The devcontainer provides a consistent, isolated development environment with all necessary tools pre-configured.

## Overview

This devcontainer is built on a Node.js base image (to support Claude Code) but is primarily configured for Python development with Poetry. It includes:

- Python 3.11 with Poetry for dependency management
- Git with helpful configuration
- Pre-commit hooks for code quality
- Claude Code integration
- VS Code extensions and settings
- Network security via a firewall configuration

## Key Files

- `devcontainer.json`: Defines the VS Code configuration, extensions, and settings
- `Dockerfile`: Builds the container image with all required dependencies
- `init-poetry.sh`: Configures Poetry and installs project dependencies
- `init-git.sh`: Sets up sensible Git defaults within the container
- `init-precommit.sh`: Installs and configures pre-commit hooks
- `init-firewall.sh`: Configures network security rules
- `rename_project.py`: Utility script to rename the template project

## Initialization Process

When the container starts for the first time, it runs the following initialization scripts:

1. `init-firewall.sh`: Sets up network security
2. `init-poetry.sh`: Configures Poetry and installs dependencies
3. `init-git.sh`: Configures Git settings
4. `init-precommit.sh`: Sets up pre-commit hooks

## Customization

### Adding New Dependencies

To add new dependencies:

```bash
# Add runtime dependencies
poetry add package-name

# Add development dependencies
poetry add --group dev package-name
```

### Adding VS Code Extensions

To add more VS Code extensions, edit the `devcontainer.json` file and add to the `extensions` array.

### Modifying the Firewall

If you need to allow additional domains or services, edit the `init-firewall.sh` script and add the required domains to the list.

### Troubleshooting

If you encounter issues with the devcontainer:

1. Check the terminal output during container creation for error messages
2. Verify that all initialization scripts completed successfully
3. For network issues, check the firewall configuration in `init-firewall.sh`
4. For Python/Poetry issues, ensure your `pyproject.toml` is correctly configured

## Security Notes

- The devcontainer includes a restrictive firewall that only allows specific domains
- Pre-commit hooks help prevent committing sensitive information
- The container runs as a non-root user (node) for improved security