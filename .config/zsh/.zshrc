# XDG config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_CONFIG_HOME=$HOME/.config
export XDG_DATA_HOME=$HOME/.local/share
export XDG_STATE_HOME=$HOME/.local/state

# initialize shell with brew
if [[ $(uname) == "Darwin" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Use fzf
source <(fzf --zsh)

# Use emacs keymap as the default.
bindkey -e

# init prompt pure
autoload -U promptinit; promptinit
prompt pure
precmd_awsprofile() {
	RPROMPT="%F{$prompt_pure_colors[git:branch]}${AWS_PROFILE}%f"
}
add-zsh-hook precmd precmd_awsprofile

# Completion files: Use XDG dirs
[ -d "$XDG_CACHE_HOME"/zsh ] || mkdir -p "$XDG_CACHE_HOME"/zsh
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME"/zsh/zcompcache
zstyle ':completion:*' menu select

# load plugins
autoload -U compinit && compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-$ZSH_VERSION
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $HOMEBREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh

# History options
HISTSIZE="10000"
SAVEHIST="10000"
HISTFILE="$XDG_STATE_HOME"/zsh/history
mkdir -p "$(dirname "$HISTFILE")"

setopt HIST_FCNTL_LOCK
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt autocd

# keymap
WORDCHARS=""

bindkey -M emacs '^[[H' beginning-of-line
bindkey -M emacs '^[[F' end-of-line
bindkey -M emacs '^[[1;5C' forward-word
bindkey -M emacs '^[[1;5D' backward-word
bindkey -M emacs '^[[3~' delete-char
bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down

# setup go
export GOPATH="$XDG_DATA_HOME"/go
export GOCACHE="$XDG_CACHE_HOME"/go-build
export GOMODCACHE="$XDG_CACHE_HOME"/go/mod
export GOPRIVATE="github.com/shopware-saas"

# Add paths
export PATH="$(brew --prefix python@3.12)/bin:$PATH"
export PATH="$PATH:$HOME/bin"
export PATH="$PATH:/usr/local/bin"
export PATH="$PATH:$GOPATH/bin"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:/Applications/WezTerm.app/Contents/MacOS"

export EDITOR="nvim"
export DOCKER_BUILDKIT=1
export PURE_GIT_PULL=0
export MANPAGER="nvim +Man!"
export AWS_PAGER=""
export HISTORY_SUBSTRING_SEARCH_PREFIXED="1"
export TG_PROVIDER_CACHE="1"
export TG_PROVIDER_CACHE_DIR="$XDG_CACHE_HOME/terragrunt"
#export OPENAI_API_BASE="https://api.githubcopilot.com"
#export OPENAI_API_KEY="$(jq -r 'to_entries[0].value.oauth_token' ~/.config/github-copilot/apps.json)"

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export TF_PLUGIN_CACHE_DIR="$XDG_CACHE_HOME/terraform"
export TF_CLI_CONFIG_FILE="$XDG_CONFIG_HOME/terraform/config.tfrc"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"
export HOMEBREW_BUNDLE_FILE="$XDG_CONFIG_HOME/brewfile/Brewfile"
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
export COMPOSER_HOME="$XDG_CONFIG_HOME"/composer
export AWS_CONFIG_FILE="$XDG_CONFIG_HOME"/aws/config

# Aliases
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'

alias tmux="tmux -u"
alias lg="lazygit"
alias lgdot="lg -w $HOME -g $HOME/dotfiles/"
alias cat="bat -pp"
alias catt="bat"
alias awslocal="aws --profile local"
alias sso="aws sso login --sso-session sso"
# alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
alias mclidev="go build -C ~/opt/cloud/mcli -o mcli main.go && ~/opt/cloud/mcli/mcli"
alias claude="$HOME/.claude/local/claude"

# File system
alias ls='eza --group-directories-first'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
alias cd="zd"
zd() {
  if [ $# -eq 0 ]; then
    builtin cd ~ && return
  elif [ -d "$1" ]; then
    builtin cd "$1"
  else
    z "$@" && printf "\U000F17A9 " && pwd || echo "Error: Directory not found"
  fi
}

# dotfiles
alias config="git --git-dir=$HOME/dotfiles/ --work-tree=$HOME"

# custom scripts
for f in $XDG_CONFIG_HOME/zsh/scripts.d/*; do source $f; done
for f in $XDG_CONFIG_HOME/zsh/scripts.private.d/*; do source $f; done


. "$HOME/.local/share/../bin/env"

export _ZO_DATA_DIR="$XDG_DATA_HOME"
eval "$(zoxide init zsh)"

