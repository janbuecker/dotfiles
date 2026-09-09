# Dotfiles

Zsh, git and CLI tooling for a mac and a linux dev VM as workstations, and a
handful of LXCs.

One rule: **a file is active on a machine if it is checked out there.** No
profile, no environment variable, no marker file. Both machine types use the
same bare repository with `$HOME` as the work tree, and differ only in a
sparse-checkout list:

| machine      | list                                   |
| ------------ | -------------------------------------- |
| workstation  | `.config/dotfiles/exclude.workstation` |
| server / LXC | `.config/dotfiles/exclude.server`      |

"Why is this file not here?" is answered by
`cat $HOME/dotfiles/info/sparse-checkout` (`$HOME/.dotfiles` on a server).

## Server / LXC

```bash
sudo apt install -y zsh git curl vim

curl -fsSL https://raw.githubusercontent.com/janbuecker/dotfiles/main/install.sh | sh
```

Everything else comes from [mise](https://mise.jdx.dev) into `$HOME`, no root
required: both the binaries and the zsh plugins, pinned in
`.config/mise/conf.d/server.toml`.

Re-run `install.sh` to update, not `git pull` - the exclude list has to be
re-derived from the new commit first, or a file encrypted upstream since the
last run arrives as an unreadable blob. A server never commits, so local edits
to tracked files are moved aside to `.bak` and replaced.

## Workstation

Steps 1 and 2 differ per OS. Everything after them is the same.

### 1. Prerequisites

**macOS** - the command line tools:

```bash
xcode-select --install
```

**Debian / Ubuntu** - Homebrew needs a compiler and basic tools, and zsh is
not installed by default:

```bash
sudo apt-get update
sudo apt-get install -y build-essential procps curl file git zsh
chsh -s "$(command -v zsh)"
```

### 2. Homebrew

**macOS:**

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
```

**Debian / Ubuntu:**

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

`rc.d/10-env.zsh` finds either prefix by itself, so the `eval` is only needed
for the rest of this shell.

### 3. Dotfiles

```bash
git clone --bare https://github.com/janbuecker/dotfiles.git $HOME/dotfiles

alias config='git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'
config config --local status.showUntrackedFiles no
config config --local remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
config fetch origin

config config --local core.sparseCheckout true
config show HEAD:.config/dotfiles/exclude.workstation \
  > $HOME/dotfiles/info/sparse-checkout
config checkout
```

The refspec is not optional: a `--bare` clone has no `origin/main` ref, so
without it `config status` cannot show ahead/behind. And `config checkout`
overwrites an existing file at a tracked path with no warning and no backup,
so move those aside first.

### 4. Packages and secrets

```bash
brew bundle --file .config/brewfile/Brewfile

op document get gitcrypt --force | config crypt unlock -   # or
config crypt unlock gitcrypt.key
```

Casks are skipped on Linux, so `op`, `tflint`, `goreleaser-pro` and
`claude-code` have to come from somewhere else there.

Restart the shell.

### 5. macOS extras

```bash
defaults write -g NSWindowShouldDragOnGesture -bool true   # drag with ctrl+cmd
sudo cp $XDG_CONFIG_HOME/us-altgr-intl.keylayout /Library/Keyboard\ Layouts
```

Reboot afterwards.

A new config needs no plumbing. The file is already in the work tree, so
`config add .config/bat/config` is the whole workflow.

## Layout

```
.config/zsh/
  .zshenv          XDG dirs and ZDOTDIR, read by every zsh
  .zshrc           loader only
  rc.d/            portable, every machine
    10-env.zsh       brew/mise bootstrap, PATH, editor, history, completion
    20-plugins.zsh   plugins, prompt, keybindings
    30-tools.zsh     aliases, tool integrations, helpers
  rc.work.d/       workstation only
    40-dev.zsh       go, projects dir, terraform, docker, dotfiles helpers
    50-aws.zsh       aws environment, ecs/ec2/cognito helpers
    60-darwin.zsh    1Password agent, mac paths
    70-private.zsh   sources scripts.private.d once decrypted
  rc.local.d/      per-machine, untracked
```

Numbering is load order and runs 10-70 across both directories. It carries one
real constraint: completion before the plugins, since syntax highlighting
expects `compinit`, and keybindings after them.

`.config/git/config` is portable and pulls in `.config/git/config.work` by
relative path, so it resolves only where that file is checked out. It has to
stay off a server: it signs commits with an ssh key held in 1Password, so
every commit on a box without that agent fails.

## Secrets

Encrypted with [git-crypt](https://github.com/AGWA/git-crypt); the set is
listed in `.gitattributes`. `install.sh` turns each of those paths into a
sparse-checkout exclude, so encrypting a file is the same edit as keeping it
off every server.

No server holds the key, so the blobs in its clone are unreadable regardless.
The exclusions are there to stop anything trying to *parse* one: an encrypted
`~/.ssh/config` stops ssh reading its config at all.
