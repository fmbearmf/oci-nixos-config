{
  description = "A very cool flake";

  inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
        flake-utils.url = "github:numtide/flake-utils";
        nix-minecraft.url = "github:Infinidoge/nix-minecraft";
        gamblepert.url = "github:fmbearmf/gamblepert";
        nix-minecraft.inputs.nixpkgs.follows = "nixpkgs";
        simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-25.05";
  };

  #nixConfig = {
    #extra-substituters = [ "https://colmena.cachix.org" ];
    #extra-trusted-public-keys = [ "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg=" ];
  #};

  outputs = { self, nixpkgs, flake-utils, simple-nixos-mailserver, gamblepert, ... }@inputs:
        let
                system = "aarch64-linux";
                pkgs = import nixpkgs { inherit system; };
        in
        {
                nixosConfigurations.fatso = nixpkgs.lib.nixosSystem {
                        system = "aarch64-linux";
                        modules = [
                                ( ./fatso/configuration.nix )
                                ( simple-nixos-mailserver.nixosModule )
                                { nixpkgs.overlays = [ inputs.nix-minecraft.overlay ]; }
                        ];
                        specialArgs = { inherit inputs; };
                };
    };
}
