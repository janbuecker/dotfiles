{ config, pkgs, lib, ... }:

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
    git 
    ripgrep
    wget
    curl
    unzip
    zip
    htop
    jq
    go
    awscli2
    golangci-lint
    terraform_1
    php
    phpPackages.composer
    glab
    docker-compose
    gnupg
    temporal
    xsel
    fzf
    zsh
    oh-my-zsh
    alacritty
    bitwarden-cli
    git-crypt
    jpegoptim
    unrar
    direnv
    python39
    python39Packages.pip
    dig
  ];

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      plugins = with pkgs.vimPlugins; [
        nerdtree
        nerdtree-git-plugin
        vim-nerdtree-tabs

        vim-gitgutter

        lightline-vim

        dracula-vim

        popup-nvim
        plenary-nvim
        telescope-nvim

        nvim-treesitter
        nvim-treesitter-textobjects
        nvim-lspconfig

        lspsaga-nvim
      ];
      extraConfig = ''
        ${builtins.readFile ./apps/nvim/defaults.vim}
        ${builtins.readFile ./apps/nvim/go.vim}

        lua << EOF
          ${builtins.readFile ./apps/nvim/lsp.lua}
          ${builtins.readFile ./apps/nvim/lspsaga.lua}
          ${builtins.readFile ./apps/nvim/treesitter.lua}
        EOF
      '';
  };

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
          EDITOR = "nvim";
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
  
  programs.alacritty = {
      enable = false;
      settings = {
          colors.primary = {
              background = "#282a36";
              foreground = "#f8f8f2";
          };
          colors.normal = {
              black = "#000000";
              red = "#ff5555";
              green = "#50fa7b";
              yellow = "#f1fa8c";
              blue = "#caa9fa";
              magenta = "#ff79c6";
              cyan = "#8be9fd";
              white = "#bfbfbf";
          };
          colors.bright = {
              black = "#575b70";
              red = "#ff6e67";
              green = "#5af78e";
              yellow = "#f4f99d";
              blue = "#caa9fa";
              magenta = "#ff92d0";
              cyan = "#9aedfe";
              white = "#e6e6e6";
          };
          hints.enabled = [
            {
                regex = "(ipfs:|ipns:|magnet:|mailto:|gemini:|gopher:|https:|http:|news:|file:|git:|ssh:|ftp:)[^\u0000-\u001F\u007F-\u009F<>\\\"\\s{-}\\^⟨⟩`]+";
                command = "xdg-open";
                post_processing = true;

                mouse.enabled = true;
                mouse.mods = "Control";

                binding.key = "U";
                binding.mods = "Control|Shift";
            }
          ];
          key_bindings = [
            { 
                key = "Return";
                mods = "Control|Shift";
                action = "SpawnNewInstance";
            }
          ];
      };
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
  };

  # fix for gpg
  home.activation = {
      fixgpg = lib.hm.dag.entryAfter ["writeBoundary"] ''
        chmod 700 ~/.gnupg
      '';
  };
}
