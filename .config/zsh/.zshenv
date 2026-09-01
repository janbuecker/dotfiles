# Read for every zsh (interactive or not), so anything that scripts and
# non-interactive shells also need belongs here rather than in .zshrc.

# XDG base directories
export XDG_CACHE_HOME=$HOME/.cache
export XDG_CONFIG_HOME=$HOME/.config
export XDG_DATA_HOME=$HOME/.local/share
export XDG_STATE_HOME=$HOME/.local/state

# Respect an existing ZDOTDIR so the config can be loaded from a checkout
# other than $XDG_CONFIG_HOME/zsh (used for testing).
export ZDOTDIR=${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}
