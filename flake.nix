{
  description = "A very cool flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-volatile.url = "github:nixos/nixpkgs/nixos-unstable";
    comin = {
      url = "github:nlewo/comin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-volatile, comin, ... }@inputs:
  {
        nixosConfigurations = {
                fatso = nixpkgs.lib.nixosSystem rec {
                        system = "aarch64-linux";
                        specialArgs = {
			        inherit self;
			        pkgs-unstable = import nixpkgs-volatile {
			        	inherit system;
			        	config.allowUnfree = true;
			        };
		        };
                        modules = [
                                ./fatso/configuration.nix
                                comin.nixosModules.comin
                        ];
                };
        };
  };
}
