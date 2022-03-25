{ config, pkgs, ... }:

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
    docker-compose_2
    gnupg
    neovim
    temporal
    xsel
    fzf
    zsh
    oh-my-zsh
    alacritty
    bitwarden-cli
    git-crypt
  ];

  programs.gpg.enable = true;
  programs.git = {
      enable = true;

      signing.key = "C87088800768BC0E";
      signing.signByDefault = true;

      userEmail = "j.buecker@shopware.com";
      userName = "Jan Bücker";

      aliases = {
        rs = "restore --staged";
        amend = "commit --maned --reuse-message=HEAD";
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
      oh-my-zsh = {
          enable = true;
          plugins = ["git" "docker" "docker-compose" "aws" "safe-paste"];
      };
      localVariables = {
          EDITOR = "nvim";
      };
      shellAliases = {
        pbcopy = "xsel --clipboard --input";
        open = "xdg-open";
        adminer = "php -S 0.0.0.0:8080 $HOME/Downloads/adminer.php";
        ykrestart = "gpgconf --reload scdaemon && gpgconf --kill gpg-agent &&
        gpg-connect-agent updatestartuptty /bye";
        vim = "nvim";
        vi = "nvim";
        asume = ". awsume";
        ssh = "TERM=xterm-256color ssh";
      };
      initExtra = ''
        source .oh-my-zsh/custom/themes/honukai.zsh-theme

        export GPG_TTY="$(tty)"
        gpg-connect-agent /bye
        export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"

cdp () {
    cd $(~/bin/dir_select "$@");
}

ecsexec () {
    if [ "$1" = "" ]; then echo "missing version"; return; fi
    if [ "$2" = "fpm" ]; then
        containerName=fpm
        serviceName=shopware
    elif [ "$2" = "nginx" ]; then
        containerName=nginx
        serviceName=shopware
    elif [ "$2" = "kraftwork" ]; then
        containerName=kraftwork
        serviceName=kraftwork
    else
        echo "invalid target - kraftwork or fpm"
        return
    fi

    taskID=$(aws ecs list-tasks --cluster shopware-application --service-name $serviceName-$1 | jq '.taskArns[0]' -r | cut -d'/' -f3)
    aws ecs execute-command --interactive --command /bin/bash --task $taskID --cluster shopware-application --container $containerName
}
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

  home.file.".oh-my-zsh/custom/themes/honukai.zsh-theme".source =
  ./honukai.zsh-theme;
}
