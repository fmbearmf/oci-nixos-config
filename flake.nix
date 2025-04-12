{
  description = "A very cool flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs, ... }@inputs:
  {
        nixosConfigurations = {
                fatso = nixpkgs.lib.nixosSystem {
                        system = "aarch64-linux";
                        modules = [
                                ./fatso/configuration.nix
                        ];
                };
        };
  };
}
