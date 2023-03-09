{ config, pkgs, lib, ... }:
let
  unstable = import <unstable> { config = { allowUnfree = true; }; };
  php = pkgs.php82.buildEnv { extraConfig = "memory_limit = 4G"; };
in {
  home.username = "jbuecker";
  home.homeDirectory = "/Users/jbuecker";
  home.stateVersion = "22.11";
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
    qemu
    # colima # wait for 0.5.4 for rosetta
    coreutils
    curl
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
    htop
    jpegoptim
    jq
    lazygit
    mysql80
    natscli
    neovim
    nixfmt
    nodejs
    php
    phpPackages.composer
    phpPackages.phpstan
    phpPackages.psalm
    pigz
    pinentry_mac
    postgresql
    ripgrep
    rm-improved
    rust-analyzer
    rustc
    rustfmt
    shellcheck
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
  ];

  home.activation = {
    tfswitch = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${pkgs.tfswitch}/bin/tfswitch 1.3.6
    '';
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.exa = {
    enable = true;
    enableAliases = true;
  };

  programs.bottom = { enable = true; };

  programs.go = {
    enable = true;
    package = pkgs.go_1_20;
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
      push.default = "simple";
      fetch.prune = true;
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
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
      # theme = "gnzh";
      theme = "amuse";
      plugins = [ "git" "docker" "aws" ];
    };
    localVariables = {
      PATH =
        "$PATH:/usr/local/bin:$GOPATH/bin:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/Library/Python/3.9/bin:$HOME/bin:${pkgs.nodejs}/bin";
    };
    sessionVariables = {
      DOCKER_BUILDKIT = 1;
      RUSTFLAGS =
        "-L /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib";
      RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
      XDG_CONFIG_HOME = "$HOME/.config";
      MANPAGER = "nvim +Man!";
    };
    shellAliases = {
      # pbcopy = "xsel --clipboard --input"; # linux only
      # open = "xdg-open"; # linux only
      # ykrestart = "gpgconf --reload scdaemon && gpgconf --kill gpg-agent && gpg-connect-agent updatestartuptty /bye"; # linux only
      adminer = "php -S 0.0.0.0:8080 $HOME/Downloads/adminer.php";
      awsume = ". awsume";
      hm = "home-manager";
      vim = "nvim";
      tmux = "tmux -u";
      lg = "lazygit";
      cat = ''bat -pp --theme "Visual Studio Dark+"'';
      catt = ''bat --theme "Visual Studio Dark+"'';
      cp = "cp -i";
      mv = "mv -i";
      rm = "rm -i";
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
    ".gnupg/pubkey.pub".source =
      config.lib.file.mkOutOfStoreSymlink ./apps/gnupg/pubkey.pub;
    ".gnupg/gpg-agent.conf".source =
      config.lib.file.mkOutOfStoreSymlink ./apps/gnupg/gpg-agent.conf;
    ".config/lvim/config.lua".source =
      config.lib.file.mkOutOfStoreSymlink ./apps/lvim/config.lua;
    ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink ./apps/nvim;
    ".config/kitty/kitty.conf".source =
      config.lib.file.mkOutOfStoreSymlink ./apps/kitty/kitty.conf;
    ".config/kitty/kanagawa.conf".source =
      config.lib.file.mkOutOfStoreSymlink ./apps/kitty/kanagawa.conf;
    ".colima/_templates/default.yaml".source =
      config.lib.file.mkOutOfStoreSymlink ./apps/colima/colima.yaml;
    ".ssh/allowed_signers".text = ''
      j.buecker@shopware.com namespaces="git" ${
        builtins.readFile ./apps/ssh/id_ed25519.pub
      }'';

    # secrets
    "intelephense/licence.txt".source =
      config.lib.file.mkOutOfStoreSymlink ./secrets/intelephense.txt;
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
