{
  description = "NixOS configs for my personal workplace";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations."laptop" = nixpkgs.lib.nixosSystem {
      modules = [
        ./hardware/uiu57o6a.nix
        ./networking.nix
        ./os/audio.nix
        ./os/linux.nix
        ./os/nixos.nix
        ./os/ui.nix
        ./security.nix
        ./users.nix
        ./wifi.nix
      ];
      specialArgs = { inherit inputs; };
      system = "x86_64-linux";
    };
    nixosConfigurations."nucbox" = nixpkgs.lib.nixosSystem {
      modules = [
        ./hardware/nucbox.nix
        ./hardware/wd-5T.nix
        ./networking.nix
        ./os/audio.nix
        ./os/linux.nix
        ./os/nixos.nix
        ./os/ui.nix
        ./security.nix
        ./users.nix
        ./wifi.nix
      ];
      specialArgs = { inherit inputs; };
      system = "x86_64-linux";
    };
  };
}
