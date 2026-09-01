# Homebrew, if present. Never assume it: a server or LXC has none.
for _brew in /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew /usr/local/bin/brew; do
    if [[ -x $_brew ]]; then
        eval "$($_brew shellenv)"
        break
    fi
done
unset _brew

# Go
export GOPATH="$XDG_DATA_HOME"/go
export GOCACHE="$XDG_CACHE_HOME"/go/build
export GOMODCACHE="$XDG_CACHE_HOME"/go/mod

# Paths
export PATH="$PATH:$HOME/bin"
export PATH="$PATH:/usr/local/bin"
export PATH="$PATH:$GOPATH/bin"
export PATH="$PATH:$HOME/.local/bin"

# mise provides the tooling where there is no Homebrew, so it has to run
# before anything below probes for a command. Needs $HOME/.local/bin on PATH.
(( $+commands[mise] )) && eval "$(mise activate zsh)"

if (( $+commands[nvim] )); then
    export EDITOR="nvim"
    export MANPAGER="nvim +Man!"
else
    export EDITOR="vi"
fi
# --- history ---------------------------------------------------------------

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
# --- completion ------------------------------------------------------------

# Completion cache in XDG dirs
[ -d "$XDG_CACHE_HOME"/zsh ] || mkdir -p "$XDG_CACHE_HOME"/zsh
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME"/zsh/zcompcache
zstyle ':completion:*' menu select

autoload -Uz compinit

ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-$ZSH_VERSION"
mkdir -p "${ZSH_COMPDUMP:h}"

# Reuse the dump unless a config file changed since it was written. The config
# is spread over rc.d now, so checking .zshrc alone is not enough.
_compdump_fresh=0
if [[ -f $ZSH_COMPDUMP ]]; then
    _compdump_fresh=1
    for _f in $ZDOTDIR/.zshrc $ZDOTDIR/rc.d/*.zsh(N) $ZDOTDIR/rc.full.d/*.zsh(N); do
        if [[ $_f -nt $ZSH_COMPDUMP ]]; then
            _compdump_fresh=0
            break
        fi
    done
fi

if (( _compdump_fresh )); then
    compinit -C -d "$ZSH_COMPDUMP"
else
    compinit -d "$ZSH_COMPDUMP"
fi
unset _compdump_fresh _f
