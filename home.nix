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

  # nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
  #   inherit pkgs;
  # };

  # php = pkgs.php83.buildEnv {
  #   extraConfig = "memory_limit = 4G";
  #   extensions = (
  #     { enabled, all }:
  #     enabled
  #     ++ (with all; [
  #       redis
  #       grpc
  #       opentelemetry
  #     ])
  #   );
  # };
  # phpPackages = pkgs.php83.packages;

in
# terragrunt = pkgs.stdenv.mkDerivation {
#   name = "terragrunt";
#   phases = [ "installPhase" ];
#   installPhase = ''
#     install -D $src $out/bin/terragrunt
#   '';
#   src = pkgs.fetchurl {
#     name = "terragrunt";
#     url = "https://github.com/gruntwork-io/terragrunt/releases/download/v0.68.3/terragrunt_darwin_arm64";
#     sha256 = "08da30q020lsx09anjvvhfsksk3w93r34bz92w7jrgjd8453kg6z";
#   };
# };
#
# golangci-lint-version = "1.61.0";
# golangci-lint = pkgs.stdenv.mkDerivation {
#   name = "golangci-lint";
#   phases = [ "installPhase" ];
#   installPhase = ''
#     install -D $src/golangci-lint $out/bin/golangci-lint
#   '';
#   src = pkgs.fetchzip {
#     name = "golangci-lint";
#     url = "https://github.com/golangci/golangci-lint/releases/download/v${golangci-lint-version}/golangci-lint-${golangci-lint-version}-darwin-arm64.tar.gz";
#     sha256 = "0v67xf2fv9ikcnzbmfkkhl855dr8p6fdswwg58xrxnjxlwxdgx1j";
#   };
# };
{
  home.username = "jbuecker";
  home.homeDirectory = "/Users/jbuecker";
  home.stateVersion = "24.05";
  home.sessionVariables = {
    EDITOR = "nvim";
  };
  manual.manpages.enable = false;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # configure home paths
    #xdg.enable = true;

  # neovim nightly
  # nixpkgs.overlays = [
  #   (import (
  #     builtins.fetchTarball {
  #       url = "https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz";
  #     }
  #   ))
  # ];

  home.packages = with pkgs; [
    direnv
    natscli
    templ
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # programs.go = {
  #   enable = true;
  #   package = unstable.go_1_22;
  #   goPrivate = [ "gitlab.shopware.com" ];
  #   goPath = "opt/go";
  # };

  # programs.git = {
  #   enable = true;
  #
  #   signing.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJlKV62/B496z2BR02s2HKI62QlDaPeXCbyDrs2TWODw";
  #   signing.signByDefault = true;
  #
  #   userEmail = "j.buecker@shopware.com";
  #   userName = "Jan Bücker";
  #
  #   aliases = {
  #     rs = "restore --staged";
  #     amend = "commit --amend --reuse-message=HEAD";
  #   };
  #
  #   extraConfig = {
  #     pull.rebase = true;
  #     push.autoSetupRemote = true;
  #     push.default = "simple";
  #     fetch.prune = true;
  #     init.defaultBranch = "main";
  #     commit.template = "~/.config/git/commit";
  #
  #     gpg = {
  #       format = "ssh";
  #       ssh = {
  #         program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
  #         allowedSignersFile = "~/.ssh/allowed_signers";
  #       };
  #     };
  #
  #     url = {
  #       "https://github.com/" = {
  #         insteadOf = "git@github.com:";
  #       };
  #       "https://gitlab.shopware.com/" = {
  #         insteadOf = "git@gitlab.shopware.com:";
  #       };
  #     };
  #
  #     credential = {
  #       guiPrompt = "false";
  #       credentialStore = "cache";
  #       cacheOptions = "--timeout 21600";
  #       gitLabAuthModes = "browser";
  #       helper = [
  #         "cache"
  #         "oauth"
  #       ];
  #
  #       "https://gitlab.shopware.com" = {
  #         oauthClientId = "27dbdada9445855de26ad7fd4f3f0e0eb30f31ee618cdbcc2987d3ba652e6f6d";
  #         oauthScopes = "read_repository write_repository";
  #         oauthAuthURL = "/oauth/authorize";
  #         oauthTokenURL = "/oauth/token";
  #       };
  #     };
  #   };
  #
  #   ignores = [
  #     ".DS_Store"
  #     ".AppleDouble"
  #     ".LSOverride"
  #
  #     "._*"
  #
  #     ".DocumentRevisions-V100"
  #     ".fseventsd"
  #     ".Spotlight-V100"
  #     ".TemporaryItems"
  #     ".Trashes"
  #     ".VolumeIcon.icns"
  #     ".com.apple.timemachine.donotpresent"
  #     ".AppleDB"
  #     ".AppleDesktop"
  #     "Network Trash Folder"
  #     "Temporary Items"
  #     ".apdisk"
  #   ];
  # };

  programs.zsh = {
    enable = true;
    autocd = true;
    dotDir = ".config/zsh";
    defaultKeymap = "emacs";
    autosuggestion = {
      enable = true;
    };
    syntaxHighlighting = {
      enable = true;
    };
    historySubstringSearch = {
      enable = true;
    };
    history = {
      expireDuplicatesFirst = true;
      extended = true;
      ignoreAllDups = true;
      ignoreSpace = true;
    };
    # localVariables = {
      # PATH = builtins.concatStringsSep ":" [
      #   "$PATH"
      #   "$HOME/bin"
      #   "/usr/local/bin"
      #   "$GOPATH/bin"
      #   "$HOME/.local/bin"
      #   "${pkgs.nodejs}/bin"
      #   "/Applications/WezTerm.app/Contents/MacOS"
      # ];
    # };
    # sessionVariables = {
    #   DOCKER_BUILDKIT = 1;
    #   PURE_GIT_PULL = 0;
    #   MANPAGER = "nvim +Man!";
    #   AWS_PAGER = "";
    #   TF_PLUGIN_CACHE_DIR = "$HOME/.cache/terraform";
    #   HISTORY_SUBSTRING_SEARCH_PREFIXED = "1";
    #   RIPGREP_CONFIG_PATH = "$HOME/.config/ripgrep/config";
    #   TERRAGRUNT_PROVIDER_CACHE = "1";
    # };
    # shellAliases = {
    #   hm = "home-manager";
    #   tmux = "tmux -u";
    #   lg = "lazygit";
    #   lzd = "lazydocker";
    #   cat = "bat -pp";
    #   catt = "bat";
    #   cp = "cp -i";
    #   mv = "mv -i";
    #   rm = "rm -i";
    #   fdd = "fd --type directory --search-path `git rev-parse --show-toplevel` | fzf";
    #   awslocal = "aws --profile local";
    #   sso = "aws sso login --sso-session sso";
    #   tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
    #   mclidev = "go build -C ~/opt/cloud/mcli -o mcli main.go && ~/opt/cloud/mcli/mcli";
    #   gopro = "export GORELEASER_KEY=$(op item get Goreleaser --fields \"label=license key\")";
    # };
    initExtra = ''
      WORDCHARS=""

      autoload -Uz bashcompinit && bashcompinit
      complete -C 'aws_completer' aws

      zstyle ':completion:*' menu select

      bindkey -M emacs '^[[H' beginning-of-line
      bindkey -M emacs '^[[F' end-of-line
      bindkey -M emacs '^[[1;5C' forward-word
      bindkey -M emacs '^[[1;5D' backward-word
      bindkey -M emacs '^[[3~' delete-char

      eval "$(/opt/homebrew/bin/brew shellenv)"
      source <(fzf --zsh)

    export XDG_CACHE_HOME=$HOME/.cache
    export XDG_CONFIG_HOME=$HOME/.config
    export XDG_DATA_HOME=$HOME/.local/share
    export XDG_STATE_HOME=$HOME/.local/state

        export PATH="$PATH:$HOME/bin"
        export PATH="$PATH:/usr/local/bin"
        export PATH="$PATH:$GOPATH/bin"
        export PATH="$PATH:$HOME/.local/bin"
        export PATH="$PATH:/Applications/WezTerm.app/Contents/MacOS"


      export DOCKER_BUILDKIT=1
      export PURE_GIT_PULL=0
      export MANPAGER="nvim +Man!"
      export AWS_PAGER=""
      export HISTORY_SUBSTRING_SEARCH_PREFIXED="1"
      export TERRAGRUNT_PROVIDER_CACHE="1"

      export ZDOTDIR=$XDG_CONFIG_HOME/zsh
      export TF_PLUGIN_CACHE_DIR="$XDG_CACHE_HOME/terraform"
      export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"
      export HOMEBREW_BUNDLE_FILE="$XDG_CONFIG_HOME/brewfile/Brewfile"

      export GOPATH="$XDG_DATA_HOME/opt/go"
      export GOPRIVATE="gitlab.shopware.com"

      alias -g ...='../..'
      alias -g ....='../../..'
      alias -g .....='../../../..'
      alias -g ......='../../../../..'
      alias -g config="git --git-dir=$HOME/dotfiles/ --work-tree=$HOME"
      alias -g ls="eza"
      alias -g hm="home-manager"
      alias -g tmux="tmux -u"
      alias -g lg="lazygit"
      alias -g lzd="lazydocker"
      alias -g cat="bat -pp"
      alias -g catt="bat"
      alias -g cp="cp -i"
      alias -g mv="mv -i"
      alias -g rm="rm -i"
      alias -g fdd="fd --type directory --search-path `git rev-parse --show-toplevel` | fzf"
      alias -g awslocal="aws --profile local"
      alias -g sso="aws sso login --sso-session sso"
      alias -g tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
      alias -g mclidev="go build -C ~/opt/cloud/mcli -o mcli main.go && ~/opt/cloud/mcli/mcli"

      gopro() {
        export GORELEASER_KEY=$(op item get Goreleaser --fields "label=license key")
      }


      # custom scripts
      ${builtins.readFile ./apps/zsh/scripts.sh}

      # custom secret scripts
      ${builtins.readFile ./secrets/zsh/scripts.sh}
    '';
    plugins = [
      {
        name = "pure";
        src = pkgs.fetchFromGitHub {
          owner = "sindresorhus";
          repo = "pure";
          rev = "v1.23.0";
          sha256 = "1jcb5cg1539iy89vm9d59g8lnp3dm0yv88mmlhkp9zwx3bihwr06";
        };
      }
      {
        name = "docker";
        src = pkgs.fetchFromGitHub {
          owner = "greymd";
          repo = "docker-zsh-completion";
          rev = "69560d170ac8082d6086bba9b1691a4a024c32bd";
          sha256 = "0d8jq8vf4zimwfgr22w5q6bkg26bbqfki1x1fmf28jsic58lz9j9";
        };
      }
    ];
  };

  # programs.fzf = {
  #   enable = true;
  #   enableZshIntegration = true;
  # };
  #
  home.file = {
    ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink ./apps/nvim;
    ".ssh/allowed_signers".text = ''j.buecker@shopware.com namespaces="git" ${builtins.readFile ./apps/ssh/id_ed25519.pub}'';
    # ".config/lazygit/config.yml".source = config.lib.file.mkOutOfStoreSymlink ./apps/lazygit/config.yml;
    ".config/bat/config".source = config.lib.file.mkOutOfStoreSymlink ./apps/bat/config;
    ".config/wezterm".source = config.lib.file.mkOutOfStoreSymlink ./apps/wezterm;
    ".config/git/commit".text = ''
      # feat: (new feature for the user, not a new feature for build script)
      # fix: (bug fix for the user, not a fix to a build script)
      # docs: (changes to the documentation)
      # style: (formatting, missing semi colons, etc; no production code change)
      # refactor: (refactoring production code, eg. renaming a variable)
      # test: (adding missing tests, refactoring tests; no production code change)
      # chore: (updating grunt tasks etc; no production code change)

      # Why?
      # - ...
      #
      # What?
      # - ...
    '';
    ".config/ripgrep/config".text = ''
      --hidden
      --glob=!.git/*
      --smart-case
    '';

    # secrets
    "intelephense/licence.txt".source = config.lib.file.mkOutOfStoreSymlink ./secrets/intelephense.txt;
    ".aws/config".source = config.lib.file.mkOutOfStoreSymlink ./secrets/aws/config;
    ".aws/credentials".source = config.lib.file.mkOutOfStoreSymlink ./secrets/aws/credentials;
    ".ssh/config".source = config.lib.file.mkOutOfStoreSymlink ./secrets/ssh/config;
  };
}
