#!/bin/sh
# Install the shell config on a machine without Homebrew (server, LXC, VM).
#
#   curl -fsSL https://raw.githubusercontent.com/janbuecker/dotfiles/main/install.sh | sh
#   ./install.sh full     # also load the mac/work layer
#
# The mac uses the bare repo checkout instead, see README.
set -eu

PROFILE="${1:-core}"
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/janbuecker/dotfiles}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

case "$PROFILE" in
    core | full) ;;
    *)
        echo "usage: $0 [core|full]" >&2
        exit 2
        ;;
esac

say() { printf '\033[1m==>\033[0m %s\n' "$1"; }

# 1. prerequisites
missing=""
for cmd in git curl zsh; do
    command -v "$cmd" >/dev/null 2>&1 || missing="$missing $cmd"
done
if [ -n "$missing" ]; then
    echo "missing:$missing" >&2
    echo "install them first, e.g. sudo apt install -y zsh git curl" >&2
    exit 1
fi

# 2. repository
if [ -d "$DOTFILES_DIR/.git" ]; then
    say "updating $DOTFILES_DIR"
    git -C "$DOTFILES_DIR" pull --ff-only || echo "  pull failed, using the existing checkout"
else
    say "cloning into $DOTFILES_DIR"
    git clone --quiet "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# 3. profile marker, read by .zshrc
printf '%s\n' "$PROFILE" > "$DOTFILES_DIR/.config/zsh/profile"
say "profile: $PROFILE"

# 4. symlinks - an explicit allowlist, so nothing else in the repo (encrypted
#    ssh and aws config, mac-only tools) can end up in $HOME
link() {
    src="$DOTFILES_DIR/$1"
    dst="$2"

    [ -e "$src" ] || return 0
    mkdir -p "$(dirname "$dst")"

    if [ -L "$dst" ]; then
        rm "$dst"
    elif [ -e "$dst" ]; then
        mv "$dst" "$dst.bak"
        echo "  backed up $dst -> $dst.bak"
    fi

    ln -s "$src" "$dst"
    echo "  $dst"
}

say "linking config"
link ".zshenv" "$HOME/.zshenv"
link ".config/zsh" "$XDG_CONFIG_HOME/zsh"
link ".config/git/config" "$XDG_CONFIG_HOME/git/config"
link ".config/git/ignore" "$XDG_CONFIG_HOME/git/ignore"
link ".config/bat" "$XDG_CONFIG_HOME/bat"
link ".config/ripgrep" "$XDG_CONFIG_HOME/ripgrep"
link ".config/mise/config.core.toml" "$XDG_CONFIG_HOME/mise/config.toml"

# 5. tooling: cli binaries and the zsh plugins, all via mise
if command -v mise >/dev/null 2>&1; then
    mise_bin="$(command -v mise)"
elif [ -x "$HOME/.local/bin/mise" ]; then
    mise_bin="$HOME/.local/bin/mise"
else
    say "installing mise"
    curl -fsSL https://mise.run | sh
    mise_bin="$HOME/.local/bin/mise"
fi

say "installing tools"
"$mise_bin" install --yes

# 6. login shell
zsh_bin="$(command -v zsh)"
case "${SHELL:-}" in
    *zsh) ;;
    *)
        say "setting login shell"
        if ! chsh -s "$zsh_bin" 2>/dev/null; then
            echo "  could not change it, run this yourself: chsh -s $zsh_bin"
        fi
        ;;
esac

say "done, start a new shell"
