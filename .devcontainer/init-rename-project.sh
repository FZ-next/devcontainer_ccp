#!/bin/bash
# Script to automatically rename the Python project structure inside the container
# to match the workspace folder name

set -e

# Get the workspace folder name (project name)
PROJECT_NAME=$(basename /workspace)
OLD_NAME="python_project"

# Skip if the project name is already python_project
if [ "$PROJECT_NAME" = "$OLD_NAME" ]; then
    echo "Project name is already $OLD_NAME, skipping rename."
    exit 0
fi

echo "Renaming Python project from $OLD_NAME to $PROJECT_NAME..."

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
replace_in_file "/workspace/pyproject.toml" "name = \"$OLD_NAME\"" "name = \"$PROJECT_NAME\""
replace_in_file "/workspace/pyproject.toml" "\"$OLD_NAME\"" "\"$PROJECT_NAME\""

# Rename src directory if it exists and target doesn't
if [ -d "/workspace/src/$OLD_NAME" ] && [ ! -d "/workspace/src/$PROJECT_NAME" ]; then
    mv "/workspace/src/$OLD_NAME" "/workspace/src/$PROJECT_NAME"
    echo "Renamed directory src/$OLD_NAME -> src/$PROJECT_NAME"
else
    echo "Warning: Cannot rename source directory, either source doesn't exist or target already exists."
fi

# Update imports in Python files
echo "Updating Python imports..."
find /workspace/src /workspace/tests -name "*.py" -type f | while read -r file; do
    replace_in_file "$file" "$OLD_NAME" "$PROJECT_NAME"
done

# Update README and CLAUDE.md
replace_in_file "/workspace/README.md" "$OLD_NAME" "$PROJECT_NAME"
replace_in_file "/workspace/CLAUDE.md" "$OLD_NAME" "$PROJECT_NAME"

echo "Project successfully renamed from '$OLD_NAME' to '$PROJECT_NAME'!"
