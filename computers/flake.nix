{
  description = "NixOS configs for my personal workplace";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
  };

  outputs = { nixpkgs, ... }@inputs:
    let
      common = [
        ./networking.nix
        ./os/audio.nix
        ./os/linux.nix
        ./os/nixos.nix
        ./os/ui.nix
        ./security.nix
        ./users.nix
        ./wifi.nix
      ];
      mkHost = modules: nixpkgs.lib.nixosSystem {
        modules = common ++ modules;
        specialArgs = { inherit inputs; };
      };
    in {
      nixosConfigurations = {
        laptop = mkHost [ ./hardware/uiu57o6a.nix ];
        nucbox = mkHost [ ./hardware/nucbox.nix ./hardware/wd-5T.nix ./llm.nix ];
      };
    };
}
