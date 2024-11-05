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

# load plugins
autoload -U compinit && compinit
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $HOMEBREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh

# History options
HISTSIZE="10000"
SAVEHIST="10000"
HISTFILE="$HOME/.zsh_history"
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

zstyle ':completion:*' menu select

bindkey -M emacs '^[[H' beginning-of-line
bindkey -M emacs '^[[F' end-of-line
bindkey -M emacs '^[[1;5C' forward-word
bindkey -M emacs '^[[1;5D' backward-word
bindkey -M emacs '^[[3~' delete-char
bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down

# XDG config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_CONFIG_HOME=$HOME/.config
export XDG_DATA_HOME=$HOME/.local/share
export XDG_STATE_HOME=$HOME/.local/state

# Add paths
export PATH="$PATH:$HOME/bin"
export PATH="$PATH:/usr/local/bin"
export PATH="$PATH:$GOPATH/bin"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:/Applications/WezTerm.app/Contents/MacOS"

export DOCKER_BUILDKIT=1
export PURE_GIT_PULL=0
export MANPAGER="nvim +Man!"
export AWS_PAGER=""
export HISTORY_SUBSTRING_SEARCH_PREFIXED="1"
export TERRAGRUNT_PROVIDER_CACHE="1"

export ZDOTDIR=$XDG_CONFIG_HOME/zsh
export TF_PLUGIN_CACHE_DIR="$XDG_CACHE_HOME/terraform"
export TF_CLI_CONFIG_FILE="$XDG_CONFIG_HOME/terraform/config.tfrc"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"
export HOMEBREW_BUNDLE_FILE="$XDG_CONFIG_HOME/brewfile/Brewfile"

export GOPATH="$XDG_DATA_HOME/opt/go"
export GOPRIVATE="gitlab.shopware.com"

# Aliases
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'
alias ls="eza"
alias hm="home-manager"
alias tmux="tmux -u"
alias lg="lazygit"
alias lzd="lazydocker"
alias cat="bat -pp"
alias catt="bat"
alias cp="cp -i"
alias mv="mv -i"
alias rm="rm -i"
alias awslocal="aws --profile local"
alias sso="aws sso login --sso-session sso"
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
alias mclidev="go build -C ~/opt/cloud/mcli -o mcli main.go && ~/opt/cloud/mcli/mcli"

# dotfiles
alias config="git --git-dir=$HOME/dotfiles/ --work-tree=$HOME"

# custom scripts
for f in $XDG_CONFIG_HOME/zsh/scripts.d/*; do source $f; done
for f in $XDG_CONFIG_HOME/zsh/scripts.private.d/*; do source $f; done

