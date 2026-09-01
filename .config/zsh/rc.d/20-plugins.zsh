# Plugins come from Homebrew on the mac and from mise everywhere else, so
# there is a single package manager per machine and no bespoke clone step.
# Layouts: brew  <prefix>/share/<name>/<name>.zsh
#          mise  <data>/installs/http-<name>/latest/<name>.zsh
_mise_installs="${MISE_DATA_DIR:-$XDG_DATA_HOME/mise}/installs"

_load_plugin() {
    local name=$1 p
    for p in \
        ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/share/$name/$name.zsh} \
        $_mise_installs/http-$name/latest/$name.zsh
    do
        if [[ -r $p ]]; then
            source $p
            return 0
        fi
    done
    return 1
}

export HISTORY_SUBSTRING_SEARCH_PREFIXED="1"

_load_plugin zsh-autosuggestions
_load_plugin zsh-syntax-highlighting
# has to stay after syntax-highlighting
_load_plugin zsh-history-substring-search

unset -f _load_plugin

# Prompt. pure ships as a completion function: Homebrew puts it in fpath via
# shellenv, the mise install has to be added by hand.
export PURE_GIT_PULL=0
autoload -Uz add-zsh-hook
[[ -d $_mise_installs/http-pure/latest ]] && fpath+=($_mise_installs/http-pure/latest)
unset _mise_installs

autoload -U promptinit
promptinit

if (( ${prompt_themes[(Ie)pure]} )); then
    prompt pure
else
    # Keep a usable prompt on a box where pure is not installed
    PS1='%n@%m %~ %# '
fi
# --- keybindings, below the plugins that define the widgets ----------------

# Use emacs keymap as the default.
bindkey -e

WORDCHARS=""

bindkey -M emacs '^[[H' beginning-of-line
bindkey -M emacs '^[[F' end-of-line
bindkey -M emacs '^[[1;5C' forward-word
bindkey -M emacs '^[[1;5D' backward-word
bindkey -M emacs '^[[3~' delete-char

# Provided by zsh-history-substring-search, loaded in 30-plugins.zsh
if (( $+widgets[history-substring-search-up] )); then
    bindkey "^[[A" history-substring-search-up
    bindkey "^[[B" history-substring-search-down
fi
