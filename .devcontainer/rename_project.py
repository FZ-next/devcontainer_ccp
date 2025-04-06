#!/usr/bin/env python3
"""
Project Renaming Script

This script renames the template project from 'python_project' to a name of your choice.
It updates:
1. The directory name
2. Import statements
3. pyproject.toml configuration
4. Test imports
5. README and other documentation

Usage:
    python .devcontainer/rename_project.py new_project_name
"""
import os
import re
import shutil
import sys
from pathlib import Path


def validate_project_name(name: str) -> bool:
    """Validate that the project name is a valid Python package name."""
    return bool(re.match(r'^[a-z][a-z0-9_]*$', name))


def find_and_replace_in_file(file_path: Path, old_name: str, new_name: str) -> None:
    """Replace all occurrences of old_name with new_name in a file."""
    if not file_path.exists():
        print(f"Warning: File {file_path} does not exist, skipping.")
        return

    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()

    # Replace the old project name with the new one
    updated_content = content.replace(old_name, new_name)
    
    # Handle PascalCase variants (e.g., in class names)
    old_pascal = ''.join(word.capitalize() for word in old_name.split('_'))
    new_pascal = ''.join(word.capitalize() for word in new_name.split('_'))
    updated_content = updated_content.replace(old_pascal, new_pascal)

    with open(file_path, 'w', encoding='utf-8') as file:
        file.write(updated_content)
    
    print(f"Updated {file_path}")


def rename_directory(old_path: Path, new_path: Path) -> None:
    """Rename a directory from old_path to new_path."""
    if not old_path.exists():
        print(f"Warning: Directory {old_path} does not exist, skipping.")
        return
    
    if new_path.exists():
        print(f"Error: Directory {new_path} already exists.")
        sys.exit(1)
    
    shutil.move(old_path, new_path)
    print(f"Renamed directory {old_path} -> {new_path}")


def main() -> None:
    """Main function to rename the project."""
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} new_project_name")
        sys.exit(1)
    
    # Get the new name from command line arguments
    new_name = sys.argv[1]
    old_name = "python_project"
    
    # Validate project name
    if not validate_project_name(new_name):
        print(f"Error: '{new_name}' is not a valid Python package name.")
        print("Project names should start with a letter and contain only lowercase letters, numbers, and underscores.")
        sys.exit(1)
    
    # Find workspace directory
    workspace_dir = Path('/workspace')
    if not workspace_dir.exists():
        # If not in devcontainer, assume current directory
        workspace_dir = Path('.')
    
    # Change to workspace directory
    os.chdir(workspace_dir)
    
    # Confirm with the user
    print(f"This will rename the project from '{old_name}' to '{new_name}'.")
    confirmation = input("Do you want to continue? [y/N]: ")
    if confirmation.lower() != 'y':
        print("Operation canceled.")
        sys.exit(0)
    
    # Update files in the repository
    files_to_update = [
        Path('pyproject.toml'),
        Path('README.md'),
        Path('CLAUDE.md'),
        Path('tests/test_example.py'),
        Path('tests/__init__.py'),
    ]
    
    for file_path in files_to_update:
        find_and_replace_in_file(file_path, old_name, new_name)
    
    # Rename src directory
    old_dir = Path(f'src/{old_name}')
    new_dir = Path(f'src/{new_name}')
    rename_directory(old_dir, new_dir)
    
    # Update imports in Python files
    python_files = list(Path('src').glob('**/*.py')) + list(Path('tests').glob('**/*.py'))
    for file_path in python_files:
        find_and_replace_in_file(file_path, old_name, new_name)
    
    # Update tool.ruff.isort section in pyproject.toml
    pyproject_path = Path('pyproject.toml')
    with open(pyproject_path, 'r', encoding='utf-8') as file:
        content = file.read()
    
    # Update known-first-party in ruff.isort section
    content = re.sub(
        r'(known-first-party = \[)"python_project"(\])',
        fr'\1"{new_name}"\2',
        content
    )
    
    with open(pyproject_path, 'w', encoding='utf-8') as file:
        file.write(content)
    
    print(f"\nProject successfully renamed from '{old_name}' to '{new_name}'!")
    print("\nNext steps:")
    print("1. Run 'poetry install' to update your environment")
    print("2. Run the tests to make sure everything works: 'poetry run pytest'")
    print("3. Commit the changes to your repository")


if __name__ == "__main__":
    main()