{
  description = "A very cool flake";

  inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
        colmena.url = "github:zhaofengli/colmena";
        flake-utils.url = "github:numtide/flake-utils";
  };

  nixConfig = {
    extra-substituters = [ "https://colmena.cachix.org" ];
    extra-trusted-public-keys = [ "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg=" ];
  };

  outputs = { self, nixpkgs, colmena, flake-utils, ... }:
  {
        colmenaHive = colmena.lib.makeHive self.outputs.colmena;
        colmena = {
                meta = {
                        nixpkgs = import nixpkgs {
                                system = "aarch64-linux";
                        };
                };


                fatso = {
                        deployment = {
                                targetHost = "fatso.tailc57f75.ts.net";
                                targetUser = "root";
                                buildOnTarget = true;
                                sshOptions = [
                                        "-i"
                                        "~/.ssh/nix-remote-builder"
                                ];
                        };

                        imports = [ 
                                ( ./fatso/configuration.nix )
                        ];
                };
        };
  } // flake-utils.lib.eachDefaultSystem (system:
        let
                pkgs = import nixpkgs { inherit system; };
        in
        {
        packages = {
                build = pkgs.stdenv.mkDerivation {
                        pname = "build";
                        version = "0.0.1";

                        src = null;
                        dontUnpack = true;

                        nativeBuildInputs = [
                                colmena.defaultPackage.${system}
                        ];

                        installPhase = ''
                                mkdir -p $out/bin
                                cat > $out/bin/build <<EOF
                                #!/bin/sh
                                ${colmena.defaultPackage.${system}}/bin/colmena build --experimental-flake-eval
                                EOF
                                chmod +x $out/bin/build
                        '';
                };
                apply = pkgs.stdenv.mkDerivation {
                        pname = "apply";
                        version = "0.0.1";

                        src = null;
                        dontUnpack = true;

                        nativeBuildInputs = [
                                colmena.defaultPackage.${system}
                        ];

                        installPhase = ''
                                mkdir -p $out/bin
                                cat > $out/bin/apply <<EOF
                                #!/bin/sh
                                ${colmena.defaultPackage.${system}}/bin/colmena apply --experimental-flake-eval
                                EOF
                                chmod +x $out/bin/apply
                        '';
                };
        };

        devShells.default = pkgs.mkShell {
                buildInputs = [ colmena.defaultPackage.${system} ];
        };
    });
}
