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
autoload -Uz compinit

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
ZSH_CONFIG="${ZDOTDIR:-$HOME}/.zshrc"
ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-$ZSH_VERSION"

mkdir -p "${ZSH_COMPDUMP:h}"

if [[ -f "$ZSH_COMPDUMP" && "$ZSH_COMPDUMP" -nt "$ZSH_CONFIG" ]]; then
  compinit -C -d "$ZSH_COMPDUMP"
else
  compinit -d "$ZSH_COMPDUMP"
fi

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
export GOCACHE="$XDG_CACHE_HOME"/go/build
export GOMODCACHE="$XDG_CACHE_HOME"/go/mod
export GOPRIVATE="github.com/shopware-saas"

# Add paths
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
export FZF_DEFAULT_OPTS="--height='~40%' --layout=reverse --info=inline"
export GITHUB_TOKEN=$(gh auth token)

export _ZO_DATA_DIR="$XDG_DATA_HOME"
export TF_PLUGIN_CACHE_DIR="$XDG_CACHE_HOME/terraform"
export TF_CLI_CONFIG_FILE="$XDG_CONFIG_HOME/terraform/config.tfrc"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"
export HOMEBREW_BUNDLE_FILE="$XDG_CONFIG_HOME/brewfile/Brewfile"
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
export COMPOSER_HOME="$XDG_CONFIG_HOME"/composer
export AWS_CONFIG_FILE="$XDG_CONFIG_HOME"/aws/config
export GOLANGCI_LINT_CACHE="$XDG_CACHE_HOME"/golangci-lint

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
alias today='$EDITOR ~/today.md'
alias ghcr='docker login ghcr.io --username $(gh config get -h github.com user) --password $(gh config get -h github.com oauth_token)'
alias tarz="tar --use-compress-program=zstdmt"

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

# source private scripts only if they're decrypted (text files)
for f in $XDG_CONFIG_HOME/zsh/scripts.private.d/*; do
  # skip if not a regular file
  [[ -f "$f" ]] || continue

  # check if file is a text file using the file command
  # encrypted files will be detected as "data" or specific binary formats
  if ! file -b "$f" | grep -q "text"; then
    # file is likely encrypted or binary, skip silently
    continue
  fi

  source "$f"
done

# 1Password SSH agent socket for macOS
_op_sock="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
[ -S "$_op_sock" ] && export SSH_AUTH_SOCK="$_op_sock"
unset _op_sock

if command -v mise >/dev/null 2>&1; then eval "$(mise activate zsh)"; fi
if command -v zoxide >/dev/null 2>&1; then eval "$(zoxide init zsh)"; fi
if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi

