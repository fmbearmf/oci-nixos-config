{
  description = "A very cool flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    comin = {
      url = "github:nlewo/comin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, comin, ... }@inputs:
  {
        nixosConfigurations = {
                fatso = nixpkgs.lib.nixosSystem {
                        system = "aarch64-linux";
                        modules = [
                                ./fatso/configuration.nix
                                comin.nixosModules.comin
                        ];
                };
        };
  };
}
