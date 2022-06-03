{ config, pkgs, ... }:

{
  imports = [ 
    <home-manager/nix-darwin>
  ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages =
    [ 
      pkgs.kitty
      pkgs.terminal-notifier
    ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  environment.darwinConfig = "$HOME/.config/nixpkgs/darwin-configuration.nix";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina
  # programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  users.users.jbuecker = {
    name = "jbuecker";
    home = "/Users/jbuecker";
  };

  home-manager.useUserPackages = true;
  home-manager.users.jbuecker = ./home.nix;

  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [
     recursive
     (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
   ];


  # Add ability to used TouchID for sudo authentication
#  security.pam.enableSudoTouchIdAuth = true;

  system.defaults.NSGlobalDomain.InitialKeyRepeat = 100;
  system.defaults.NSGlobalDomain.KeyRepeat = 250;
}
