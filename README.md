# Installation

This repository contains my workstation configuration and can be restored using the setup below.

### 1. Install nix + home-manager

```bash
sh <(curl -L https://nixos.org/nix/install)

nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

# if not on NixOS
export NIX_PATH=$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels${NIX_PATH:+:$NIX_PATH}

nix-shell '<home-manager>' -A install
```

### 2. Clone this repository to `.config/nixpkgs/`

```bash
rm -rf .config/nixpkgs/
git clone https://github.com/janbuecker/dotfiles.git .config/nixpkgs/
```

### 3. Switch first generation

Run home-manager for the first time with this configuration

```bash
home-manager switch
```

### 4. Update the default shell to zsh

```bash
command -v zsh | sudo tee -a /etc/shells
chsh -s $(which zsh)
```

Re-login to enter zsh.

### 5. Decrypt secrets

The de/encryption requires GPG, which should be installed by now

```bash
git-crypt unlock
```
