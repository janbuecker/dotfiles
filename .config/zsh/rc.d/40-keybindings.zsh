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
