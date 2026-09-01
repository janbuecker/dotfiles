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
