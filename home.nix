{ config, pkgs, lib, ... }:
let
  unstable = import <unstable> { config = { allowUnfree = true; }; };
  php = pkgs.php83.buildEnv { extraConfig = "memory_limit = 4G"; };
  phpPackages = pkgs.php83.packages;
in {
  home.username = "jbuecker";
  home.homeDirectory = "/Users/jbuecker";
  home.stateVersion = "23.11";
  home.sessionVariables = { EDITOR = "nvim"; };
  manual.manpages.enable = false;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # neovim nightly
  # nixpkgs.overlays = [
  #   (import (builtins.fetchTarball {
  #     url =
  #       "https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz";
  #   }))
  # ];

  home.packages = with pkgs; [
    awscli2
    bandwhich
    bash
    bat
    caddy
    coreutils
    unstable.cloudflared
    direnv
    docker
    fd
    findutils
    fzf
    git-crypt
    glab
    gnugrep
    gnused
    hclfmt
    htop
    jq
    lazygit
    mysql80
    unstable.neovim-unwrapped
    nixfmt
    nodejs
    p7zip
    php
    phpPackages.composer
    phpPackages.phpstan
    phpPackages.psalm
    pigz
    postgresql
    ripgrep
    unstable.terragrunt
    terraform
    tldr
    tmux
    unrar
    unstable.ssm-session-manager-plugin
    temporal-cli
    unzip
    wget
    wireguard-go
    wireguard-tools
    zip
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.eza = {
    enable = true;
    enableAliases = true;
  };

  programs.bottom = { enable = true; };

  programs.go = {
    enable = true;
    goPrivate = [ "gitlab.shopware.com" ];
    goPath = "opt/go";
  };

  programs.git = {
    enable = true;

    signing.key =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJlKV62/B496z2BR02s2HKI62QlDaPeXCbyDrs2TWODw";
    signing.signByDefault = true;

    userEmail = "j.buecker@shopware.com";
    userName = "Jan Bücker";

    aliases = {
      rs = "restore --staged";
      amend = "commit --amend --reuse-message=HEAD";
    };

    extraConfig = {
      pull.rebase = true;
      push.autoSetupRemote = true;
      push.default = "simple";
      fetch.prune = true;
      init.defaultBranch = "main";
      gpg = {
        format = "ssh";
        ssh = {
          program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
          allowedSignersFile = "~/.ssh/allowed_signers";
        };
      };
    };

    ignores = [
      ".DS_Store"
      ".AppleDouble"
      ".LSOverride"

      "._*"

      ".DocumentRevisions-V100"
      ".fseventsd"
      ".Spotlight-V100"
      ".TemporaryItems"
      ".Trashes"
      ".VolumeIcon.icns"
      ".com.apple.timemachine.donotpresent"
      ".AppleDB"
      ".AppleDesktop"
      "Network Trash Folder"
      "Temporary Items"
      ".apdisk"
    ];
  };

  programs.zsh = {
    enable = true;
    enableCompletion = false;
    oh-my-zsh = {
      enable = true;
      theme = "amuse";
      plugins = [ "git" "docker" "aws" ];
    };
    localVariables = {
      PATH = builtins.concatStringsSep ":" [
        "$PATH"
        "/usr/local/bin"
        "$GOPATH/bin"
        "$HOME/bin"
        "$HOME/.local/bin"
        "${pkgs.nodejs}/bin"
        "/Applications/WezTerm.app/Contents/MacOS"
      ];
    };
    sessionVariables = {
      DOCKER_BUILDKIT = 1;
      XDG_CONFIG_HOME = "$HOME/.config";
      MANPAGER = "nvim +Man!";
      AWS_PAGER = "";
      TF_PLUGIN_CACHE_DIR = "$HOME/.cache/terraform";
    };
    shellAliases = {
      hm = "home-manager";
      tmux = "tmux -u";
      lg = "lazygit";
      cat = ''bat -pp --theme "Visual Studio Dark+"'';
      catt = ''bat --theme "Visual Studio Dark+"'';
      cp = "cp -i";
      mv = "mv -i";
      rm = "rm -i";
      awslocal = "aws --endpoint-url http://localhost:4566";
      sso = "aws sso login --sso-session sso";
      tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
      golangci-update =
        "${pkgs.curl}/bin/curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(${pkgs.go}/bin/go env GOPATH)/bin";
      mclidev =
        "go build -C ~/opt/cloud/mcli -o mcli main.go && ~/opt/cloud/mcli/mcli --auto-update=false";
    };
    initExtra = ''
      # 1password
      eval "$(op completion zsh)"; compdef _op op

      # custom scripts
      ${builtins.readFile ./apps/zsh/scripts.sh}

      # custom secret scripts
      ${builtins.readFile ./secrets/zsh/scripts.sh}
    '';
  };

  home.file = {
    ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink ./apps/nvim;
    ".ssh/allowed_signers".text = ''
      j.buecker@shopware.com namespaces="git" ${
        builtins.readFile ./apps/ssh/id_ed25519.pub
      }'';

    # secrets
    "intelephense/licence.txt".source =
      config.lib.file.mkOutOfStoreSymlink ./secrets/intelephense.txt;
    ".config/wezterm".source =
      config.lib.file.mkOutOfStoreSymlink ./apps/wezterm;
    ".aws/config".source =
      config.lib.file.mkOutOfStoreSymlink ./secrets/aws/config;
    ".aws/credentials".source =
      config.lib.file.mkOutOfStoreSymlink ./secrets/aws/credentials;
    ".ssh/config".source =
      config.lib.file.mkOutOfStoreSymlink ./secrets/ssh/config;
    ".netrc".source = config.lib.file.mkOutOfStoreSymlink ./secrets/netrc;
  };
}
