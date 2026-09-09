#!/bin/sh
# Install the dotfiles on a server or LXC.
#
#   curl -fsSL https://raw.githubusercontent.com/janbuecker/dotfiles/main/install.sh | sh
#
# This is the same setup a workstation uses - a bare repository with $HOME as
# the work tree - narrowed by a sparse-checkout list. There is no separate
# symlink layout and no profile to pick: a file is active on this machine if
# it is checked out here, and .config/dotfiles/exclude.server decides what is.
#
# Re-run it any time to update. A server never commits, so this tracks origin
# rather than merging: local edits to tracked files are backed up to .bak and
# replaced. Note that a plain `git pull` is NOT enough here - the exclude list
# has to be re-derived from the new commit first, or a newly encrypted file
# lands as an unreadable blob.
set -eu

DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/janbuecker/dotfiles}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

say() { printf '\033[1m==>\033[0m %s\n' "$1"; }

# 1. prerequisites
missing=""
for cmd in git curl zsh; do
    command -v "$cmd" >/dev/null 2>&1 || missing="$missing $cmd"
done
if [ -n "$missing" ]; then
    echo "missing:$missing" >&2
    echo "install them first, e.g. sudo apt install -y zsh git curl vim" >&2
    exit 1
fi

export GIT_DIR="$DOTFILES_DIR" GIT_WORK_TREE="$HOME"

# 2. repository. A --bare clone gets a mirror refspec and no tracking config,
#    so origin/<branch> would not exist and `git pull` would not work.
#    core.worktree is set because a server has no `config` alias - rc.work.d is
#    not checked out here - so `git --git-dir=~/.dotfiles <cmd>` has to work on
#    its own from any directory.
if [ ! -d "$DOTFILES_DIR" ]; then
    say "cloning into $DOTFILES_DIR"
    git clone --quiet --bare "$DOTFILES_REPO" "$DOTFILES_DIR"
    git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
    git config core.bare false
    git config core.worktree "$HOME"
    git config core.sparseCheckout true
    git config status.showUntrackedFiles no
fi

say "fetching"
git fetch --quiet --prune origin

branch="$(git symbolic-ref --short HEAD)"
if ! git rev-parse --verify --quiet "refs/remotes/origin/$branch" >/dev/null; then
    echo "error: origin has no branch '$branch'" >&2
    exit 1
fi
git update-ref "refs/heads/$branch" "refs/remotes/origin/$branch"
git config "branch.$branch.remote" origin
git config "branch.$branch.merge" "refs/heads/$branch"

# 3. what this machine gets. The tracked list, plus one exclude per git-crypt
#    path in .gitattributes, so a newly encrypted file excludes itself instead
#    of arriving as a blob that breaks the tool reading it - an encrypted
#    ~/.ssh/config stops ssh from parsing its config at all.
say "deriving the exclude list from $branch"
exclude="$DOTFILES_DIR/info/sparse-checkout"
mkdir -p "$DOTFILES_DIR/info"
git show "HEAD:.config/dotfiles/exclude.server" > "$exclude"
git show "HEAD:.gitattributes" \
    | sed -n 's#^\(/[^ ]*\) .*filter=git-crypt.*#!\1#p' >> "$exclude"

# 4. remember what is checked out right now, and the blob each file came from.
#    read-tree below replaces the index, which is what would otherwise make git
#    forget these were ever ours: a file deleted upstream then looks untracked,
#    and checkout leaves it behind as drift.
before="$(mktemp)"
after="$(mktemp)"
git ls-files -v -s | sed -n 's/^H [0-7]* \([0-9a-f]*\) [0-9]*\t\(.*\)$/\1 \2/p' \
    | sort -k2 > "$before"

# 5. populate the index and the skip-worktree bits without touching $HOME, so
#    the files about to be written can be compared against what is there.
git read-tree HEAD
git sparse-checkout reapply >/dev/null 2>&1 || true
git ls-files -v | sed -n 's/^H //p' | sort > "$after"

# 6. back up anything real that differs. A bare checkout into a populated
#    $HOME overwrites the distro's own .zshenv and friends silently, with no
#    error and no backup, so this has to happen first.
say "checking for existing files"
git ls-files -v | sed -n 's/^H //p' | while read -r p; do
    [ -e "$HOME/$p" ] || continue
    [ -L "$HOME/$p" ] && continue
    [ "$(git hash-object -- "$HOME/$p")" = "$(git rev-parse ":$p")" ] && continue
    mv "$HOME/$p" "$HOME/$p.bak"
    echo "  backed up $p -> $p.bak"
done

# 7. materialise. -f is safe now that the step above preserved anything that
#    differed from what is incoming.
say "checking out $branch"
git checkout --quiet -f "$branch"

# 8. drop what is no longer ours, either deleted upstream or newly excluded.
#    An untouched file is removed; one edited on this machine is kept as .bak.
while read -r hash path; do
    if grep -qxF "$path" "$after"; then continue; fi
    [ -e "$HOME/$path" ] || continue
    if [ "$(git hash-object -- "$HOME/$path")" = "$hash" ]; then
        rm -f "$HOME/$path"
        echo "  removed $path"
    else
        mv "$HOME/$path" "$HOME/$path.bak"
        echo "  no longer tracked, kept as $path.bak"
    fi
    rmdir "$(dirname "$HOME/$path")" 2>/dev/null || true
done < "$before"
rm -f "$before" "$after"

# 9. tooling: the cli binaries and the zsh plugins, all through mise, which
#    reads .config/mise/conf.d/server.toml straight from the checkout.
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

# 10. login shell
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

if [ -z "$(command -v nvim || command -v vim || command -v vi)" ]; then
    echo "  note: no editor found, install one: sudo apt install -y vim" >&2
fi

say "done, start a new shell"
