{
  description = "A very cool flake";

        #nixConfig = {
        #builders = "ssh://bear@fatso.tailc57f75.ts.net aarch64-linux /home/bear/.ssh/id_rsa 4 1 big-parallel";
        #};

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    colmena.url = "github:zhaofengli/colmena";
  };

  nixConfig = {
    extra-substituters = [ "https://colmena.cachix.org" ];
    extra-trusted-public-keys = [ "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg=" ];
  };

  outputs = { self, nixpkgs, colmena, ... }@inputs:
  let
        system = "x86_64-linux";
        pkgs = import nixpkgs {
                inherit system;
        };
  in
  {
                        colmenaHive = colmena.lib.makeHive self.outputs.colmena;
        colmena = {
                meta = {
                        nixpkgs = import nixpkgs { system = "x86_64-linux"; };

                        nodeNixpkgs = {
                                fatso = import nixpkgs { system = "aarch64-linux"; };
                        };
                };
        };

        fatso = {
                nixpkgs.crossSystem = {
                        system = "aarch64-linux";
                };

                deployment = {
                        targetHost = "fatso.tailc57f75.ts.net";
                        targetUser = "bear";
                        allowLocalDeployment = false;
                        buildOnTarget = true;
                };

                imports = [ ./fatso/configuration.nix ];
        };

        devShells.${system}.default = pkgs.mkShell {
                buildInputs = [
                        colmena.defaultPackage.${system}
                ];
        };
  };
}
