{
  description = "A very cool flake";

  inputs = {
    self.submodules = true;
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    nix-minecraft.inputs.nixpkgs.follows = "nixpkgs";
    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-26.05";
    gembox.url = "./gembox";
  };

  #nixConfig = {
  #extra-substituters = [ "https://colmena.cachix.org" ];
  #extra-trusted-public-keys = [ "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg=" ];
  #};

  outputs =
    {
      self,
      nixpkgs,
      gembox,
      flake-utils,
      simple-nixos-mailserver,
      ...
    }@inputs:
    let
      system = "aarch64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      nixosConfigurations.fatso = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          gembox.nixosModules.default
          (./fatso/configuration.nix)
          (simple-nixos-mailserver.nixosModule)
          { nixpkgs.overlays = [ inputs.nix-minecraft.overlay ]; }
        ];
        specialArgs = { inherit inputs; };
      };
    };
}
