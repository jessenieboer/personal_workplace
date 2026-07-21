
{ config, inputs, pkgs, unstable, ... }:
{
  home = {
    homeDirectory = "/home/jessenieboer";
    packages = with pkgs; [
      nix-prefetch-github
      unstable.devenv
    ];
    # sessionVariables = {
      #   # EDITOR = "emacs";
      # };

      # This value determines the Home Manager release that your configuration is
      # compatible with. This helps avoid breakage when a new Home Manager release
      # introduces backwards incompatible changes.
      #
      # You should not change this value, even if you update Home Manager. If you do
      # want to update the value, then make sure to first check the Home Manager
      # release notes.
      stateVersion = "25.05"; # Please read the comment before changing.
      username = "jessenieboer";
  };

  nixpkgs.config.allowUnfree = true; #for bws

  programs = {
    bash ={
      enable = true;
    };
    direnv = {
      enable = true;
      enableBashIntegration = true;
    };
    git = {
      enable = true;
      package = pkgs.git;
      settings = {
        alias = {
          st = "status --short --branch";
          co = "checkout";
          lg = "log --oneline --graph --decorate";
          hist = "log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short";
        };
        init.defaultBranch = "master";
        pull.rebase = true;
        push.autoSetupRemote = true;
        safe.directory = "*";
        user.name = "Jesse Nieboer";
        user.email = "jessenieboer@protonmail.com";
      };
    };
  };
}
