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
