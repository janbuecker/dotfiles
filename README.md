# Dotfiles

Zsh, git and CLI tooling for my machines. The shell config is split into two
profiles so the same repo works on a workstation and on a bare server:

| profile | loads                              | used on                      |
| ------- | ---------------------------------- | ---------------------------- |
| `core`  | `.config/zsh/rc.d/`                | servers, LXCs, containers    |
| `full`  | `rc.d/` + `.config/zsh/rc.full.d/` | mac and the linux dev VM     |

`core` is portable: no Homebrew, no AWS, no work tooling, and every alias and
tool init is guarded so a missing binary never shadows a real command. `full`
adds the AWS/ECS helpers, Terraform and Go settings, the 1Password agent and
the private git-crypt scripts on top.

The profile is picked in this order: `$DOTFILES_PROFILE`, then the marker file
`$ZDOTDIR/profile` written by `install.sh`, then `full` on macOS and `core`
everywhere else.

## Server / LXC

Needs `zsh`, `git` and `curl` from the distro; everything else is installed by
[mise](https://mise.jdx.dev) into `$HOME`, no root required.

```bash
sudo apt install -y zsh git curl

curl -fsSL https://raw.githubusercontent.com/janbuecker/dotfiles/main/install.sh | sh
```

This clones to `~/.dotfiles` and symlinks an explicit allowlist into `$HOME`
(zsh, git, bat, ripgrep, mise). Nothing else in the repo is touched, so the
git-crypt encrypted `.ssh/config` and AWS config never land on the machine.
Then it hands everything else to mise and sets the login shell.

Re-run it any time to update; it pulls and relinks. `install.sh full` switches
the machine to the full profile.

To install from a branch, set `DOTFILES_REF`. The script always clones the
repository's default branch otherwise, no matter which branch it was fetched
from, which would install the config from `main`:

```bash
curl -fsSL https://raw.githubusercontent.com/janbuecker/dotfiles/<branch>/install.sh \
  | DOTFILES_REF=<branch> sh
```

mise is the only package manager on a server, the same role Homebrew has on the
mac. It provides both the binaries (`fzf`, `zoxide`, `ripgrep`, `fd`, `eza`,
`bat`, `neovim`, `btop`, `jq`, `tmux`) and the zsh plugins. The plugins publish no
release binaries, so they use the `http:` backend against the GitHub source
tarball for a tag; mise strips the archive's top level directory and keeps a
`latest` symlink, so `rc.d/30-plugins.zsh` can source a stable path.

Plugin versions are pinned in `.config/mise/config.core.toml`. To upgrade one,
bump the tag in both `version` and `url`.

## Workstation (macOS)

Uses a bare repository with `$HOME` as the work tree. Homebrew stays the source
of truth for packages here; mise is only used per project.

### 1. Clone this repository to `$HOME/dotfiles`

The alias helps with some commands. The config option hides all untracked files
in `$HOME`, so git status is actually usable.

```bash
git clone --bare https://github.com/janbuecker/dotfiles.git $HOME/dotfiles

alias config='git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'
config checkout
config config --local status.showUntrackedFiles no
```

### 2. Install homebrew and packages

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

eval "$(/opt/homebrew/bin/brew shellenv)"
# eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" # for linux

brew bundle --file .config/brewfile/Brewfile
```

### 3. Decrypt secrets

The de/encryption requires the unlock key.

```bash
# 1password
op document get gitcrypt --force | config crypt unlock -

# key file
config crypt unlock gitcrypt.key
```

### 4. Restart shell (zsh)

Enviroment should be ready to be used after restarting the shell (zsh).

### 5. Fine-tuning

Reboot after the changes below are made:

```
# Drag windows anywhere with ctrl + cmd
defaults write -g NSWindowShouldDragOnGesture -bool true

# Install us-altgr-intl keyboard layout
sudo cp $XDG_CONFIG_HOME/us-altgr-intl.keylayout /Library/Keyboard\ Layouts
```

## Layout

```
.config/zsh/
  .zshenv          XDG dirs and ZDOTDIR, read by every zsh
  .zshrc           loader only, resolves the profile
  rc.d/            core, always loaded
    10-env.zsh       brew/mise bootstrap, PATH, editor, history, completion
    20-plugins.zsh   plugin loading, prompt, and the keybindings they provide
    30-tools.zsh     aliases, tool integrations, helper functions
  rc.full.d/       mac and work, only when the profile is full
    10-darwin.zsh    1Password agent, mac only paths
    20-dev.zsh       go, terraform, docker, dotfiles helpers
    30-aws.zsh       aws environment and the ecs/ec2/cognito helpers
  rc.local.d/      per-machine overrides, untracked
```

The numbering is load order, and it carries one real constraint: completion has
to run before the plugins (syntax highlighting expects `compinit`), and the
keybindings after them, since they bind widgets the plugins define.

Git config is split the same way: `.config/git/config` is portable, and
`.config/git/config.full` (commit signing, the github ssh rewrite) is pulled in
by a relative `[include]` that only resolves on machines where the whole
directory is present.

Machine-specific tweaks that should not be committed go in
`.config/zsh/rc.local.d/*.zsh`.
