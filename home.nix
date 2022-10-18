{ config, pkgs, lib, ... }:
let
  unstable = import <unstable> { config = { allowUnfree = true; }; };
  php = pkgs.php81.buildEnv { extraConfig = "memory_limit = 4G"; };
in
{
  home.username = "jbuecker";
  home.homeDirectory = "/Users/jbuecker";
  home.stateVersion = "22.05";
  home.sessionVariables = {
    EDITOR = "lvim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    rbw
    caddy
    pinentry_mac
    gcc
    tmux
    coreutils
    gnused
    gnugrep
    findutils
    ripgrep
    wget
    curl
    unzip
    zip
    htop
    jq
    pigz
    unstable.ssm-session-manager-plugin
    php
    phpPackages.composer
    phpPackages.psalm
    phpPackages.phpstan
    glab
    docker-compose
    gnupg
    temporal-cli
    xsel
    fzf
    fd
    zsh
    oh-my-zsh
    bitwarden-cli
    git-crypt
    jpegoptim
    unrar
    direnv
    wireguard-tools
    wireguard-go
    unstable.neovim
    natscli
    nodejs
    dogdns
    bandwhich
    gping
    rm-improved
    tldr
    tfswitch
    lazygit
    rustc
    rust-analyzer
    rustfmt
    cargo
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.exa = {
    enable = true;
    enableAliases = true;
  };

  programs.bottom = {
    enable = true;
  };

  programs.go = {
    enable = true;
    package = unstable.go_1_19;
    goPrivate = [ "gitlab.shopware.com" ];
    goPath = "opt/go";
  };

  programs.gpg = {
    enable = true;
    scdaemonSettings = {
      disable-ccid = true;
    };
    publicKeys = [{
      source = ./apps/gnupg/pubkey.pub;
      trust = "ultimate";
    }];
  };

  programs.git = {
    enable = true;
    package = unstable.git;

    signing.key = "C87088800768BC0E";
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
      plugins = [ "git" "docker" "docker-compose" "aws" ];
    };
    localVariables = {
      PATH = "$PATH:/usr/local/bin:$GOPATH/bin:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/Library/Python/3.8/bin:$HOME/bin";
    };
    sessionVariables = {
      DOCKER_BUILDKIT = 1;
      RUSTFLAGS = "-L /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib";
      RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
    };
    shellAliases = {
      # pbcopy = "xsel --clipboard --input"; # linux only
      open = "xdg-open";
      adminer = "php -S 0.0.0.0:8080 $HOME/Downloads/adminer.php";
      ykrestart = "gpgconf --reload scdaemon && gpgconf --kill gpg-agent && gpg-connect-agent updatestartuptty /bye";
      awsume = ". awsume";
      hm = "home-manager";
      vi = "lvim";
      vim = "lvim";
      dig = "dog";
      ping = "gping";
      tmux = "tmux -u";
      lg = "lazygit";
    };
    initExtra = ''
      # custom console theme
      source $HOME/.oh-my-zsh/custom/themes/honukai.zsh-theme

      # Yubikey setup
      export GIT_SSH="/usr/bin/ssh"
      export GPG_TTY="$(tty)"
      export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
      gpgconf --launch gpg-agent

      # custom scripts
      ${builtins.readFile ./apps/zsh/scripts.sh}
    '';
  };

  home.file = {
    ".oh-my-zsh/custom/themes/honukai.zsh-theme".source = config.lib.file.mkOutOfStoreSymlink ./apps/oh-my-zsh/honukai.zsh-theme;
    ".gnupg/pubkey.pub".source = config.lib.file.mkOutOfStoreSymlink ./apps/gnupg/pubkey.pub;
    ".gnupg/gpg-agent.conf".source = config.lib.file.mkOutOfStoreSymlink ./apps/gnupg/gpg-agent.conf;
    ".config/lvim/config.lua".source = config.lib.file.mkOutOfStoreSymlink ./apps/lvim/config.lua;

    # secrets
    ".aws/config".source = config.lib.file.mkOutOfStoreSymlink ./secrets/aws/config;
    ".aws/credentials".source = config.lib.file.mkOutOfStoreSymlink ./secrets/aws/credentials;
    ".ssh/cloud".source = config.lib.file.mkOutOfStoreSymlink ./secrets/ssh/cloud;
    ".ssh/config".source = config.lib.file.mkOutOfStoreSymlink ./secrets/ssh/config;
    ".netrc".source = config.lib.file.mkOutOfStoreSymlink ./secrets/netrc;
    ".config/wireguard/prod.private-key.gpg".source = config.lib.file.mkOutOfStoreSymlink ./secrets/wireguard/prod.private-key.gpg;
    ".config/wireguard/staging.private-key.gpg".source = config.lib.file.mkOutOfStoreSymlink ./secrets/wireguard/staging.private-key.gpg;
  };
}
