#!/bin/bash

# Git branch cleanup function
# Deletes local branches that:
# 1. Have been merged into main/master
# 2. No longer exist on the remote
# 3. Are not the current branch

git_cleanup() {
    echo "🧹 Starting git branch cleanup..."

    # Get the main branch name (could be 'main' or 'master')
    main_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
    current_branch=$(git branch --show-current)

    echo "📍 Main branch: $main_branch"
    echo "📍 Current branch: $current_branch"
    echo ""

    # Fetch latest remote info and prune deleted remote branches
    echo "🔄 Fetching latest remote info..."
    git fetch --prune
    echo ""

    # Find branches that have been merged into main
    echo "🔍 Finding merged branches..."
    merged_branches=$(git branch --merged "$main_branch" | grep -v "^\*" | grep -v "$main_branch" | grep -v "master" | xargs)

    if [ -z "$merged_branches" ]; then
        echo "✅ No merged branches to clean up"
    else
        echo "📋 Merged branches found:"
        echo "$merged_branches" | tr ' ' '\n' | sed 's/^/  - /'
        echo ""

        echo "🗑️  Deleting merged branches..."
        echo "$merged_branches" | tr ' ' '\n' | xargs -I {} git branch -d {}
        echo ""
    fi

    # Find branches whose remote tracking branch no longer exists
    echo "🔍 Finding branches with deleted remote tracking..."
    orphaned_branches=$(git for-each-ref --format='%(refname:short) %(upstream:track)' refs/heads | awk '$2 == "[gone]" {print $1}')

    if [ -z "$orphaned_branches" ]; then
        echo "✅ No orphaned branches to clean up"
    else
        echo "📋 Orphaned branches found:"
        echo "$orphaned_branches" | sed 's/^/  - /'
        echo ""

        echo "🗑️  Deleting orphaned branches..."
        echo "$orphaned_branches" | while read branch; do
            if [ "$branch" != "$current_branch" ]; then
                git branch -D "$branch"
            else
                echo "⚠️  Skipping current branch: $branch"
            fi
        done
        echo ""
    fi

    echo "✨ Git cleanup complete!"
}

# If script is executed directly (not sourced), run the function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    git_cleanup
fi