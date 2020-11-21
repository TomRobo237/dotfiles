{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.variables = {EDITOR = "vim"; };
  environment.systemPackages = with pkgs ;
    [
      # macvim Installed with homebrew because wasn't building and too lazy to find what needs to be done.
      cacert
      checkbashisms
      coreutils
      cowsay
      cpplint
      ctags
      curlFull
      direnv
      dwarf-fortress
      expect
      findutils
      fortune
      gawk
      git
      gnupg
      gnused
      hexedit
      highlight
      nodejs
      perl
      php74
      ps
      pstree
      python3
      python38Packages.virtualenv
      ranger
      rename
      rogue
      ruby
      shellcheck
      sourceHighlight
      splint
      tcl
      w3m
      wget
    ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  # services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh = {
    enable = true;  # default shell on catalina
    enableCompletion = true;
    enableSyntaxHighlighting = true;
  };
  # programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
