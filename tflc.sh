#!/bin/bash

# Check if directory argument is provided
if [ $# -eq 0 ]; then
    SEARCH_DIR="."
else
    SEARCH_DIR="$1"
fi

echo "Searching for Git repositories in $SEARCH_DIR..."

# Find all .git directories and extract the repository paths
find "$SEARCH_DIR" -name ".git" -type d 2>/dev/null | while read -r gitdir; do
    # Get the parent directory of .git, which is the repository root
    repo_path=$(dirname "$gitdir")
    
    # Run git commands in a subshell to avoid changing the current directory permanently
    (
        # Change to repository directory
        if ! cd "$repo_path" 2>/dev/null; then
            exit 1
        fi
        
        # Get the most recent commit timestamp in Unix format
        latest_commit_time=$(git log -1 --format="%at" 2>/dev/null)
        
        # If no commit was found, skip this repository
        if [ -z "$latest_commit_time" ]; then
            exit 1
        fi
        
        # Get a human-readable date for display
        human_date=$(git log -1 --format="%ad" --date=relative 2>/dev/null)
        
        # Output the timestamp and repository path in a format suitable for sorting
        echo "$latest_commit_time|$repo_path|$human_date"
        exit 0
    )
done | sort -rn | while IFS="|" read -r timestamp path human_date; do
    echo "[$human_date] $path"
done

echo "Search complete." 