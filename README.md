# Installation

This repository contains my workstation configuration and can be restored using the setup below.

### 1. Install nix + home-manager

```bash
sh <(curl -L https://nixos.org/nix/install)

nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --add https://nixos.org/channels/nixos-unstable unstable
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

### 4. Decrypt secrets

The de/encryption requires GPG or the unlock key.

```bash
// with yubikey
git-crypt unlock

// with 1password
op document get gitcrypt --force | git-crypt unlock -
```
