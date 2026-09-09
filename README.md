# Dotfiles

Zsh, git and CLI tooling for my machines: a mac and a linux dev VM as
workstations, and a handful of LXCs.

One rule decides everything:

> **A file is active on a machine if it is checked out there.**

No profile to set, no environment variable, no marker file. Both machine types
use the same bare repository with `$HOME` as the work tree, and differ only in
a sparse-checkout list. Both lists are tracked:

| machine      | list                                   |
| ------------ | -------------------------------------- |
| workstation  | `.config/dotfiles/exclude.workstation` |
| server / LXC | `.config/dotfiles/exclude.server`      |

So "why is this file not on this box?" is answered by
`cat $DOTFILES_DIR/info/sparse-checkout`, and "why does that box not get it?"
by reading one tracked file.

## Server / LXC

Needs `zsh`, `git`, `curl` and `vim` from the distro. Everything else is
installed by [mise](https://mise.jdx.dev) into `$HOME`, no root required.

```bash
sudo apt install -y zsh git curl vim

curl -fsSL https://raw.githubusercontent.com/janbuecker/dotfiles/main/install.sh | sh
```

Re-run it any time to update. A server never commits, so `install.sh` tracks
origin rather than merging: local edits to tracked files are moved aside to
`.bak` and replaced.

A plain `git pull` is deliberately *not* the update path. The exclude list has
to be re-derived from the new commit before the checkout, or a file that was
encrypted upstream since the last run arrives as an unreadable blob.

To install from a branch, set `DOTFILES_REF`. Fetching this script from a
branch is not enough, since the default branch is cloned otherwise:

```bash
curl -fsSL https://raw.githubusercontent.com/janbuecker/dotfiles/<branch>/install.sh \
  | DOTFILES_REF=<branch> sh
```

mise is the only package manager here, the role Homebrew has on the mac. It
provides both the binaries (`fzf`, `zoxide`, `ripgrep`, `fd`, `eza`, `bat`,
`btop`, `jq`, `tmux`) and the zsh plugins, from
`.config/mise/conf.d/server.toml`. mise reads `conf.d/*.toml` additively, so
that file needs no linking or renaming - it is simply checked out here and
excluded on a workstation, where Homebrew owns the same tools.

The plugins publish no release binaries, so they use the `http:` backend
against the GitHub source tarball for a tag; mise strips the archive's top
level directory and keeps a `latest` symlink, so `rc.d/20-plugins.zsh` can
source a stable path. Versions are pinned - to upgrade one, bump the tag in
both `version` and `url`.

The editor is the exception to mise owning everything: `vim` comes from the
distro. Its only mise backends build from source, which needs the exact
compiler toolchain a minimal box is meant to avoid, and neovim costs 40M
against vim's 4M for a machine that is not a workstation. On the mac Homebrew
provides neovim and `$EDITOR` prefers it whenever it is present.

## Workstation (mac, linux dev VM)

Homebrew is the source of truth for packages here; mise is only used per
project.

### 1. Clone as a bare repository

```bash
git clone --bare https://github.com/janbuecker/dotfiles.git $HOME/dotfiles

alias config='git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'
config config --local status.showUntrackedFiles no
config config --local remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
config fetch origin

# the workstation exclude list, so mise does not shadow Homebrew
config config --local core.sparseCheckout true
config show HEAD:.config/dotfiles/exclude.workstation \
  > $HOME/dotfiles/info/sparse-checkout
config checkout
```

The refspec is not optional. A `--bare` clone gets a mirror refspec and so has
no `origin/main` ref at all, which means `config status` cannot show
ahead/behind and `config pull` has nothing to track. Sparse-checkout itself
works fine with `core.bare` left at `true`.

New tool configs need no plumbing. The file is already in the work tree, so
`config add .config/bat/config` is the whole workflow - nothing to copy and
nothing to symlink, which is the reason this is a bare repo and not a symlink
farm.

### 2. Install Homebrew and packages

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

eval "$(/opt/homebrew/bin/brew shellenv)"
# eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" # for linux

brew bundle --file .config/brewfile/Brewfile
```

### 3. Decrypt secrets

```bash
# 1password
op document get gitcrypt --force | config crypt unlock -

# key file
config crypt unlock gitcrypt.key
```

Until this runs, the encrypted files on disk are still blobs. That is why
`rc.work.d/70-private.zsh` checks each private script is text before sourcing
it.

### 4. Restart the shell, then fine-tune

```bash
# Drag windows anywhere with ctrl + cmd
defaults write -g NSWindowShouldDragOnGesture -bool true

# Install us-altgr-intl keyboard layout
sudo cp $XDG_CONFIG_HOME/us-altgr-intl.keylayout /Library/Keyboard\ Layouts
```

Reboot afterwards.

## Layout

```
.config/zsh/
  .zshenv          XDG dirs and ZDOTDIR, read by every zsh
  .zshrc           loader only, sources the three directories below
  rc.d/            portable, on every machine
    10-env.zsh       brew/mise bootstrap, PATH, editor, history, completion
    20-plugins.zsh   plugin loading, prompt, and the keybindings they provide
    30-tools.zsh     aliases, tool integrations, helper functions
  rc.work.d/       workstation only, not checked out on a server
    40-dev.zsh       go, projects dir, terraform, docker, dotfiles helpers
    50-aws.zsh       aws environment and the ecs/ec2/cognito helpers
    60-darwin.zsh    1Password agent, mac only paths
    70-private.zsh   sources scripts.private.d once decrypted
  rc.local.d/      per-machine overrides, untracked
```

The numbering is the load order and runs 10-70 across both directories, so no
two files share a number. It carries one real constraint: completion has to
run before the plugins, since syntax highlighting expects `compinit`, and the
keybindings after them, since they bind widgets the plugins define.

Git config is split the same way. `.config/git/config` is portable and pulls
in `.config/git/config.work` through a relative `[include]`, which resolves
only where that file is checked out. It has to stay off a server: it turns on
commit and tag signing with an ssh key held in 1Password, so every commit on a
box without that agent fails with `Couldn't get agent socket?`, and it
rewrites https GitHub URLs to ssh, so clones fail too.

## Secrets

Encrypted with [git-crypt](https://github.com/AGWA/git-crypt); the set is
listed in `.gitattributes`. `install.sh` turns each of those paths into a
sparse-checkout exclude, so adding a secret excludes it from every server
automatically - the same edit that encrypts it.

The property that actually protects them is that no server holds the key, so
the blobs in its clone are unreadable. The exclusions are there so nothing
tries to *parse* one: an encrypted `~/.ssh/config` stops ssh from reading its
config at all. `.git-crypt/` is excluded too - the key it holds is encrypted
to a GPG key that is not there, but there is no reason to copy it to eight
machines.
