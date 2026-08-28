{
  description = "Home Manager configuration of jessenieboer";

  inputs = {
    emacs-overlay = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/emacs-overlay";
    };
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager/release-26.05";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak"; # for boosteroid
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    voxtype = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:peteonrails/voxtype/v1.0.0-rc4";
    };
    voxtype-toggle = {
      url = "git+https://git.eversole.co/James/voxtype-toggle-plasmashell.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      emacs-overlay,
      home-manager,
      nix-flatpak,
      nixpkgs,
      plasma-manager,
      ...
    }:
    let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = false;
      };
      system = "x86_64-linux";
      unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = false;  
      };
    in
    {
      homeConfigurations."jessenieboer@laptop" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home.nix
          ./security.nix
          ./software/boosteroid/boosteroid.nix
          ./software/brave/brave.nix
          ./software/docker/docker.nix
          ./software/emacs/emacs.nix
          ./software/firefox/firefox.nix
          ./software/kde/plasma.nix
          ./software/kde/programs.nix
          ./software/maestral/maestral.nix
          ./software/opencode/opencode.nix
        ];
        extraSpecialArgs = {
          inherit inputs;
          inherit unstable;
        }; 
      };
      # todo: add options to switch monitor configurations
      homeConfigurations."jessenieboer@nucbox" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home.nix
          ./security.nix
          ./software/boosteroid/boosteroid.nix
          ./software/brave/brave.nix
          ./software/docker/docker.nix
          ./software/emacs/emacs.nix
          ./software/firefox/firefox.nix
          ./software/kde/3-monitor-work-desktop.nix
          ./software/kde/plasma.nix
          ./software/kde/programs.nix
          ./software/maestral/maestral.nix
          ./software/opencode/opencode.nix
          ./software/voxtype/voxtype.nix
        ];
        extraSpecialArgs = {
          inherit inputs;
          inherit unstable;
          inherit (inputs) voxtype-toggle;   # or just pass the whole inputs
          system = "x86_64-linux";
        }; 
      };
    };
}
