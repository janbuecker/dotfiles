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
