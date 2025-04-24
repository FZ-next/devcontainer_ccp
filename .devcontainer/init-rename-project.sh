#!/bin/bash
# Script to automatically rename the Python project structure inside the container
# to match the Git repository name

set -e

# Get the Git repository name (project name)
get_repo_name() {
    local repo_name=""

    # Check if git is installed and available
    if ! command -v git &> /dev/null; then
        echo "Git is not available, using workspace folder name" >&2
        basename /workspace
        return
    fi

    # Check if current directory is a git repository
    if ! git -C /workspace rev-parse --is-inside-work-tree &> /dev/null; then
        echo "Not a git repository, using workspace folder name" >&2
        basename /workspace
        return
    fi

    # Try to get the git remote URL and extract the repository name
    if git_url=$(cd /workspace && git config --get remote.origin.url 2>/dev/null); then
        # Handle both SSH and HTTPS URLs
        if [[ $git_url == *"@"* ]]; then
            # SSH format (git@github.com:username/repo.git)
            repo_name=$(echo "$git_url" | sed -e 's/.*://g' -e 's/\.git$//g' | awk -F/ '{print $NF}')
        else
            # HTTPS format (https://github.com/username/repo.git)
            repo_name=$(echo "$git_url" | sed -e 's/.*\///g' -e 's/\.git$//g')
        fi

        # Verify we got a valid name
        if [ -n "$repo_name" ]; then
            # Convert to lower case and replace dashes with underscores for Python compatibility
            repo_name=$(echo "$repo_name" | tr '[:upper:]' '[:lower:]' | tr '-' '_')
            echo "$repo_name"
            return
        fi
    fi

    # Try to get the name from the repo folder itself as a last resort
    if [ -d "/workspace/.git" ]; then
        repo_folder=$(basename $(cd /workspace && pwd))
        echo "$repo_folder" | tr '[:upper:]' '[:lower:]' | tr '-' '_'
        return
    fi

    # Ultimate fallback to workspace folder name
    basename /workspace
}

PROJECT_NAME=$(get_repo_name)
OLD_PROJECT_NAME="python_project"
OLD_PACKAGE_NAME="python_project"

# Skip if the project name is either of the defaults
if [ "$PROJECT_NAME" = "$OLD_PROJECT_NAME" ] || [ "$PROJECT_NAME" = "$OLD_PACKAGE_NAME" ]; then
    echo "Project name is already one of the defaults ($PROJECT_NAME), skipping rename."
    exit 0
fi

echo "Renaming Python project..."
echo "- Project name from $OLD_PROJECT_NAME to $PROJECT_NAME"
echo "- Package name from $OLD_PACKAGE_NAME to $PROJECT_NAME"

# Function to replace text in files
replace_in_file() {
    local file="$1"
    local old_text="$2"
    local new_text="$3"

    if [ -f "$file" ]; then
        sed -i "s/$old_text/$new_text/g" "$file"
        echo "Updated $file"
    else
        echo "Warning: File $file does not exist, skipping."
    fi
}

# Update pyproject.toml
echo "Updating project configuration..."
replace_in_file "/workspace/pyproject.toml" "name = \"$OLD_PROJECT_NAME\"" "name = \"$PROJECT_NAME\""
replace_in_file "/workspace/pyproject.toml" "include = \"$OLD_PACKAGE_NAME\"" "include = \"$PROJECT_NAME\""
replace_in_file "/workspace/pyproject.toml" "known-first-party = \[\"$OLD_PACKAGE_NAME\"\]" "known-first-party = [\"$PROJECT_NAME\"]"

# Rename src directory if it exists and target doesn't
if [ -d "/workspace/src/$OLD_PACKAGE_NAME" ] && [ ! -d "/workspace/src/$PROJECT_NAME" ]; then
    mv "/workspace/src/$OLD_PACKAGE_NAME" "/workspace/src/$PROJECT_NAME"
    echo "Renamed directory src/$OLD_PACKAGE_NAME -> src/$PROJECT_NAME"
else
    echo "Warning: Cannot rename source directory, either source doesn't exist or target already exists."
fi

# Update imports in Python files
echo "Updating Python imports..."
find /workspace/src /workspace/tests -name "*.py" -type f | while read -r file; do
    # Replace both old names with the new name
    replace_in_file "$file" "$OLD_PROJECT_NAME" "$PROJECT_NAME"
    replace_in_file "$file" "$OLD_PACKAGE_NAME" "$PROJECT_NAME"
done

# Update README and CLAUDE.md
replace_in_file "/workspace/README.md" "$OLD_PROJECT_NAME" "$PROJECT_NAME"
replace_in_file "/workspace/README.md" "$OLD_PACKAGE_NAME" "$PROJECT_NAME"
replace_in_file "/workspace/CLAUDE.md" "$OLD_PROJECT_NAME" "$PROJECT_NAME"
replace_in_file "/workspace/CLAUDE.md" "$OLD_PACKAGE_NAME" "$PROJECT_NAME"

echo "Project successfully renamed to '$PROJECT_NAME'!"
