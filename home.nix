{
  config,
  pkgs,
  lib,
  ...
}:
let
  unstable = import <unstable> {
    config = {
      allowUnfree = true;
    };
  };

  nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
    inherit pkgs;
  };

  php = pkgs.php83.buildEnv {
    extraConfig = "memory_limit = 4G";
    extensions = (
      { enabled, all }:
      enabled
      ++ (with all; [
        redis
        grpc
      ])
    );
  };
  phpPackages = pkgs.php83.packages;

  terragrunt = pkgs.stdenv.mkDerivation {
    name = "terragrunt";
    phases = [ "installPhase" ];
    installPhase = ''
      install -D $src $out/bin/terragrunt
    '';
    src = pkgs.fetchurl {
      name = "terragrunt";
      url = "https://github.com/gruntwork-io/terragrunt/releases/download/v0.58.4/terragrunt_darwin_arm64";
      sha256 = "1cysdvgxr0xfkzgvwa1xvfmb4mvxcl9g8n83p5p757zqy1ginpsb";
    };
  };

  golangci-lint-version = "1.58.1";
  golangci-lint = pkgs.stdenv.mkDerivation {
    name = "golangci-lint";
    phases = [ "installPhase" ];
    installPhase = ''
      install -D $src/golangci-lint $out/bin/golangci-lint
    '';
    src = pkgs.fetchzip {
      name = "golangci-lint";
      url = "https://github.com/golangci/golangci-lint/releases/download/v${golangci-lint-version}/golangci-lint-${golangci-lint-version}-darwin-arm64.tar.gz";
      sha256 = "16q9w1lw4ya85yk6j46v0xfills4jidwk1r7cj9kzb9q4br4x17r";
    };
  };
in
{
  home.username = "jbuecker";
  home.homeDirectory = "/Users/jbuecker";
  home.stateVersion = "23.11";
  home.sessionVariables = {
    EDITOR = "nvim";
  };
  manual.manpages.enable = false;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # configure home paths
  xdg.enable = true;

  # neovim nightly
  # nixpkgs.overlays = [
  #   (import (builtins.fetchTarball {
  #     url =
  #       "https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz";
  #   }))
  # ];

  home.packages = with pkgs; [
    unstable.neovim-unwrapped
    air
    bandwhich
    bash
    bat
    bun
    caddy
    cargo
    coreutils
    direnv
    docker
    fd
    findutils
    fzf
    unstable.git-credential-oauth
    git-crypt
    gh
    glab
    gnugrep
    gnused
    golangci-lint
    nur.repos.goreleaser.goreleaser-pro
    hclfmt
    htop
    jq
    k9s
    kubectl
    lazygit
    mysql80
    # neovim-nightly
    nixfmt-rfc-style
    nodejs
    nodePackages.parcel
    p7zip
    php
    php.packages.composer
    php.packages.php-cs-fixer
    php.packages.phpstan
    php.packages.psalm
    pigz
    postgresql
    ripgrep
    templ
    temporal-cli
    terraform
    terragrunt
    tldr
    tmux
    unrar
    unstable._1password
    unstable.awscli2
    unstable.cloudflared
    unstable.curl
    unstable.ssm-session-manager-plugin
    unzip
    wget
    wireguard-go
    wireguard-tools
    yamlfmt
    zip
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.eza = {
    enable = true;
  };
  programs.bottom = {
    enable = true;
  };

  programs.go = {
    enable = true;
    package = unstable.go_1_22;
    goPrivate = [ "gitlab.shopware.com" ];
    goPath = "opt/go";
  };

  programs.git = {
    enable = true;

    signing.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJlKV62/B496z2BR02s2HKI62QlDaPeXCbyDrs2TWODw";
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

      credential.helper = [
        "cache"
        "oauth"
      ];

      url = {
        "https://github.com/" = {
          insteadOf = "git@github.com:";
        };
        "https://gitlab.shopware.com/" = {
          insteadOf = "git@gitlab.shopware.com:";
        };
      };

      credential."https://gitlab.shopware.com" = {
        oauthClientId = "27dbdada9445855de26ad7fd4f3f0e0eb30f31ee618cdbcc2987d3ba652e6f6d";
        oauthScopes = "read_repository write_repository";
        oauthAuthURL = "/oauth/authorize";
        oauthTokenURL = "/oauth/token";
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
      plugins = [
        "git"
        "docker"
        "aws"
        "fzf"
      ];
    };
    localVariables = {
      PATH = builtins.concatStringsSep ":" [
        "$PATH"
        "$HOME/bin"
        "/usr/local/bin"
        "$GOPATH/bin"
        "$HOME/.local/bin"
        "${pkgs.nodejs}/bin"
        "/Applications/WezTerm.app/Contents/MacOS"
      ];
    };
    sessionVariables = {
      DOCKER_BUILDKIT = 1;
      MANPAGER = "nvim +Man!";
      AWS_PAGER = "";
      TF_PLUGIN_CACHE_DIR = "$HOME/.cache/terraform";
      TERRAGRUNT_PROVIDER_CACHE = 1;
    };
    shellAliases = {
      hm = "home-manager";
      tmux = "tmux -u";
      lg = "lazygit";
      cat = "bat -pp";
      catt = "bat";
      cp = "cp -i";
      mv = "mv -i";
      rm = "rm -i";
      fdd = "fd --type directory --search-path `git rev-parse --show-toplevel` | fzf";
      awslocal = "aws --endpoint-url http://localhost:4566";
      sso = "aws sso login --sso-session sso";
      tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
      golangci-update = "${config.home.homeDirectory}/.nix-profile/bin/curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(${config.home.homeDirectory}/.nix-profile/bin/go env GOPATH)/bin";
      mclidev = "go build -C ~/opt/cloud/mcli -o mcli main.go && ~/opt/cloud/mcli/mcli";
      gopro = "export GORELEASER_KEY=$(op item get Goreleaser --fields \"label=license key\")";
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
    ".ssh/allowed_signers".text = ''j.buecker@shopware.com namespaces="git" ${builtins.readFile ./apps/ssh/id_ed25519.pub}'';
    ".config/lazygit/config.yml".source = config.lib.file.mkOutOfStoreSymlink ./apps/lazygit/config.yml;
    ".config/bat/config".source = config.lib.file.mkOutOfStoreSymlink ./apps/bat/config;
    ".config/wezterm".source = config.lib.file.mkOutOfStoreSymlink ./apps/wezterm;

    # secrets
    "intelephense/licence.txt".source = config.lib.file.mkOutOfStoreSymlink ./secrets/intelephense.txt;
    ".aws/config".source = config.lib.file.mkOutOfStoreSymlink ./secrets/aws/config;
    ".aws/credentials".source = config.lib.file.mkOutOfStoreSymlink ./secrets/aws/credentials;
    ".ssh/config".source = config.lib.file.mkOutOfStoreSymlink ./secrets/ssh/config;
    ".netrc".source = config.lib.file.mkOutOfStoreSymlink ./secrets/netrc;
  };
}
