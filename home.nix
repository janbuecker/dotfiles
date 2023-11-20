{ config, pkgs, lib, ... }:
let
  unstable = import <unstable> { config = { allowUnfree = true; }; };
  php = pkgs.php82.buildEnv { extraConfig = "memory_limit = 4G"; };
  phpPackages = pkgs.php82.packages;
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
    cargo
    coreutils
    curl
    unstable.cloudflared
    direnv
    docker
    fd
    findutils
    fzf
    git-crypt
    glab
    gnugrep
    gnupg
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
    pinentry_mac
    postgresql
    ripgrep
    rm-improved
    shellcheck
    unstable.terragrunt
    tfswitch
    tldr
    tmux
    unrar
    unstable.ssm-session-manager-plugin
    unstable.temporal-cli
    unzip
    wget
    wireguard-go
    wireguard-tools
    xsel
    yubikey-manager
    zip

    # macOS only
    darwin.apple_sdk.frameworks.Security
  ];

  home.activation = {
    tfswitch = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${pkgs.tfswitch}/bin/tfswitch -u
    '';
  };

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
    package = unstable.go_1_21;
    goPrivate = [ "gitlab.shopware.com" ];
    goPath = "opt/go";
  };

  programs.git = {
    enable = true;
    package = unstable.git;

    # signing.key = "C87088800768BC0E";
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
      PATH =
        "$PATH:/usr/local/bin:$GOPATH/bin:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/Library/Python/3.9/bin:$HOME/bin:${pkgs.nodejs}/bin:/Applications/WezTerm.app/Contents/MacOS";
    };
    sessionVariables = {
      DOCKER_BUILDKIT = 1;
      XDG_CONFIG_HOME = "$HOME/.config";
      MANPAGER = "nvim +Man!";
      AWS_PAGER = "";
      TERRAGRUNT_IAM_ASSUME_ROLE_SESSION_NAME = "j.buecker@shopware.com";
      TF_VAR_AWS_ROLE_SESSION_NAME = "j.buecker@shopware.com";
    };
    shellAliases = {
      # pbcopy = "xsel --clipboard --input"; # linux only
      # open = "xdg-open"; # linux only
      adminer = "php -S 0.0.0.0:8080 $HOME/Downloads/adminer.php";
      # awsume = ". awsume";
      hm = "home-manager";
      vim = "nvim";
      tmux = "tmux -u";
      lg = "lazygit";
      cat = ''bat -pp --theme "Visual Studio Dark+"'';
      catt = ''bat --theme "Visual Studio Dark+"'';
      cp = "cp -i";
      mv = "mv -i";
      rm = "rm -i";
      awslocal = "aws --endpoint-url http://localhost:4566";
      tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
      golangci-update = "${pkgs.curl}/bin/curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(${pkgs.go}/bin/go env GOPATH)/bin";
    };
    initExtra = ''
      # 1password integration
      # source ~/.config/op/plugins.sh
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
    ".ssh/cloud".source =
      config.lib.file.mkOutOfStoreSymlink ./secrets/ssh/cloud;
    ".ssh/config".source =
      config.lib.file.mkOutOfStoreSymlink ./secrets/ssh/config;
    ".netrc".source = config.lib.file.mkOutOfStoreSymlink ./secrets/netrc;
    ".config/wireguard/prod.private-key.gpg".source =
      config.lib.file.mkOutOfStoreSymlink
      ./secrets/wireguard/prod.private-key.gpg;
    ".config/wireguard/staging.private-key.gpg".source =
      config.lib.file.mkOutOfStoreSymlink
      ./secrets/wireguard/staging.private-key.gpg;
  };
}
