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
