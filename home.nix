{ config, pkgs, lib, ... }:
let
  unstable = import <unstable> { config = { allowUnfree = true; }; };
in
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "jbuecker";
  home.homeDirectory = "/home/jbuecker";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [ 
    ripgrep
    wget
    curl
    unzip
    zip
    htop
    jq
    go
    unstable.awscli2
    unstable.golangci-lint
    unstable.terraform_1
    php
    phpPackages.composer
    glab
    docker-compose
    gnupg
    unstable.temporal
    xsel
    fzf
    zsh
    oh-my-zsh
    bitwarden-cli
    git-crypt
    jpegoptim
    unrar
    direnv
    dig
    wireguard-tools
    regctl
    unstable.neovim
    natscli
    nodejs
  ];

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.go = {
    enable = true;
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
          plugins = ["git" "docker" "docker-compose" "aws"];
      };
      localVariables = {
          EDITOR = "lvim";
          PATH = "$PATH:$GOPATH/bin:$HOME/.local/bin"; # fix for pip deps
      };
      sessionVariables = {
          DOCKER_BUILDKIT = 1;
      };
      shellAliases = {
        pbcopy = "xsel --clipboard --input";
        open = "xdg-open";
        adminer = "php -S 0.0.0.0:8080 $HOME/Downloads/adminer.php";
        ykrestart = "gpgconf --reload scdaemon && gpgconf --kill gpg-agent && gpg-connect-agent updatestartuptty /bye";
        awsume = ". awsume";
        ssh = "TERM=xterm-256color ssh";
        hm = "home-manager";
        vi = "lvim";
        vim = "lvim";
      };
      initExtra = ''
        # custom console theme
        source $HOME/.oh-my-zsh/custom/themes/honukai.zsh-theme

        # Yubikey setup
        export GPG_TTY="$(tty)"
        gpg-connect-agent /bye
        export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
        export GIT_SSH="/usr/bin/ssh"

        # custom scripts
        ${builtins.readFile ./apps/zsh/scripts.sh}
      '';
  };
  
  programs.kitty = {
    enable = true;
    theme = "Dracula";
    extraConfig = ''
        mouse_map left click ungrabbed no-op
        mouse_map ctrl+left release grabbed,ungrabbed mouse_handle_click link
    '';
  };

  services = {
    gpg-agent = {
        enable = true;
        enableSshSupport = true;
        defaultCacheTtl = 60;
        maxCacheTtl = 120;
        pinentryFlavor = "qt";
    };
  };

  home.file = {
      ".oh-my-zsh/custom/themes/honukai.zsh-theme".source = config.lib.file.mkOutOfStoreSymlink ./apps/oh-my-zsh/honukai.zsh-theme;
      ".config/alacritty/alacritty.yml".source = config.lib.file.mkOutOfStoreSymlink ./apps/alacritty/alacritty.yml;
      ".gnupg/pubkey.pub".source = config.lib.file.mkOutOfStoreSymlink ./apps/gnupg/pubkey.pub;
      
      # secrets
      ".aws/config".source = config.lib.file.mkOutOfStoreSymlink ./secrets/aws/config;
      ".aws/credentials".source = config.lib.file.mkOutOfStoreSymlink ./secrets/aws/credentials;
      ".ssh/cloud".source = config.lib.file.mkOutOfStoreSymlink ./secrets/ssh/cloud;
      ".ssh/config".source = config.lib.file.mkOutOfStoreSymlink ./secrets/ssh/config;
      ".netrc".source = config.lib.file.mkOutOfStoreSymlink ./secrets/netrc;
      ".config/wireguard/prod.private-key.gpg".source = config.lib.file.mkOutOfStoreSymlink ./secrets/wireguard/prod.private-key.gpg;
      ".config/wireguard/staging.private-key.gpg".source = config.lib.file.mkOutOfStoreSymlink ./secrets/wireguard/staging.private-key.gpg;
  };

  # fix for gpg
  home.activation = {
      fixgpg = lib.hm.dag.entryAfter ["writeBoundary"] ''
        chmod 700 ~/.gnupg
      '';
  };
}
