alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'

alias tmux="tmux -u"
alias today='$EDITOR ~/today.md'

# Guarded, so a missing tool does not shadow the real command
(( $+commands[lazygit] )) && alias lg="lazygit"

if (( $+commands[bat] )); then
    alias cat="bat -pp"
    alias catt="bat"
fi

# File system
alias lsa='ls -a'
if (( $+commands[eza] )); then
    alias ls='eza --group-directories-first'
    alias lt='eza --tree --level=2 --long --icons --git'
    alias lta='lt -a'
fi

if (( $+commands[fzf] )); then
    if (( $+commands[bat] )); then
        alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
    else
        alias ff="fzf --preview 'cat {}'"
    fi
fi
# --- tool integrations -----------------------------------------------------

export DOCKER_BUILDKIT=1
export FZF_DEFAULT_OPTS="--height='~40%' --layout=reverse --info=inline"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"
export _ZO_DATA_DIR="$XDG_DATA_HOME"

(( $+commands[fzf] )) && source <(fzf --zsh)

if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh)"

    # cd through zoxide, falling back to a real directory argument
    zd() {
        if [ $# -eq 0 ]; then
            builtin cd ~ && return
        elif [ -d "$1" ]; then
            builtin cd "$1"
        else
            z "$@" && printf "\U000F17A9 " && pwd || echo "Error: Directory not found"
        fi
    }
    alias cd="zd"
fi
# --- functions -------------------------------------------------------------

# Deletes local branches that are merged into the main branch or whose remote
# tracking branch is gone. Never touches the current branch.
git_cleanup() {
    echo "🧹 Starting git branch cleanup..."

    # Get the main branch name (could be 'main' or 'master')
    main_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
    main_branch=${main_branch:-main}
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
