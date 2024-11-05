# Installation

This repository contains my workstation configuration and can be restored using the setup below.

### 1. Clone this repository to `$HOME/dotfiles`

Dealing with a bare repository with a working tree in `$HOME`. The alias helps with some commands.

The config option hides all untracked files in `$HOME`, so git status is actually usable.

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
