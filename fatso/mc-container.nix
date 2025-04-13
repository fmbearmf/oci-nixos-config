{ config, pkgs, inputs, lib, ... }:

{
        imports = [ 
                "${inputs.nixpkgs}/nixos/modules/profiles/minimal.nix" 
                inputs.nix-minecraft.nixosModules.minecraft-servers
        ];

        boot.isContainer = true;

        nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];
        nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
                "minecraft-server"
        ];

        services.minecraft-servers = {
                enable = true;
                eula = true;
                openFirewall = true;
                servers = {
                        cool-server1 = {
                                enable = true;
                                autoStart = true;
                                package = pkgs.fabricServers.fabric-1_21_5;
                                serverProperties = {
                                        motd = "Flakey Server";
                                        difficulty = "hard";
                                };

                                symlinks = {
                                        "mods" = pkgs.linkFarmFromDrvs "mods" (builtins.attrValues {
                                        Krypton = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/fQEb0iXm/versions/neW85eWt/krypton-0.2.9.jar"; hash = "sha256-uGYia+H2DPawZQxBuxk77PMKfsN8GEUZo3F1zZ3MY6o="; };
                                        Lithium = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/VWYoZjBF/lithium-fabric-0.16.2%2Bmc1.21.5.jar"; hash = "sha256-XqvnQxASa4M0l3JJxi5Ej6TMHUWgodOmMhwbzWuMYGg="; };
                                        VMP = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/wnEe9KBa/versions/EKg6v67t/vmp-fabric-mc1.21.5-0.2.0%2Bbeta.7.198-all.jar"; hash = "sha256-ODTIaW3NiROyf6ve0oTLUG2jLS0OChNvQmZuAsZjTdk="; };
                                        C2ME = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/VSNURh3q/versions/Wh5CxZTp/c2me-fabric-mc1.21.5-0.3.2%2Bbeta.1.0.jar"; hash = "sha256-NyMNlpYgh6hWQfRpD8jUKRgGHQCSAmtnHJoioM9rUjQ="; };
                                        ScalableLux = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/Ps1zyz6x/versions/UueJNiJn/ScalableLux-0.1.3%2Bbeta.1%2Bfabric.4039a8d-all.jar"; hash = "sha256-Vhu0ejRPdHvme5JlIoK5UaN0AClAfT5yv/pJhRshPN0="; };
                                        FerriteCore = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/uXXizFIs/versions/CtMpt7Jr/ferritecore-8.0.0-fabric.jar"; hash = "sha256-K5C/AMKlgIw8U5cSpVaRGR+HFtW/pu76ujXpxMWijuo="; };
                                        MC-258859 = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/gzfqBTYf/versions/x688NRQ5/mc-258859-1.0%2B1.21.jar"; hash = "sha256-dgHOJpPu1caJka9xZq8iJJoG+TaQmIGjBy4oFNz4eLU="; };
                                        FabricAPI = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/FZ4q3wQK/fabric-api-0.119.9%2B1.21.5.jar"; hash = "sha256-Bo9zMisO6IKtyXsgzse4sqIvfA595bnxEyLRKJBhIqo="; };
                                        YetAnotherConfigLib = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/1eAoo2KR/versions/5yBEzonb/yet_another_config_lib_v3-3.6.6%2B1.21.5-fabric.jar"; hash = "sha256-+6geCn5JUnbEd/y8I6RItHdF7OsrANfsOro5k6BsQ6E="; };
                                        Debugify = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/QwxR6Gcd/versions/rfvoZgM1/Debugify-1.21.5%2B1.0.jar"; hash = "sha256-pOwfQtL/E5yhGJRFYGO+c2soFpIgv9x/EP4YkLt6cVY="; };
                                        Almanac = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/Gi02250Z/versions/mzFZuKaS/Almanac-1.21.5-fabric-1.4.5.jar"; hash = "sha256-Ksvvf+/YmF0G2pUnrpFUWFw5d3u/xq0FMrf/MFD2GyE="; };
                                        LetMeDespawn = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/vE2FN5qn/versions/M9egl08c/letmedespawn-1.21.5-fabric-1.5.1.jar"; hash = "sha256-s/1FyEKge3+C/8Wh3/0hfBZ2gx/5+V0S0Ddqi1xPSLg="; };
                                        ServerCore = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/4WWQxlQP/versions/VK0kd4wj/servercore-fabric-1.5.10%2B1.21.5.jar"; hash = "sha256-bxRTalnUlZfP0+t1/i7vuESur0oaur8q8eV2fygxTkg="; };
                                        AlternateCurrent = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/r0v8vy1s/versions/eTNKfjl1/alternate-current-mc1.21.5-1.9.0.jar"; hash = "sha256-wh+OfvAOW7420mR6jaSPoQeYC9wNCGFdOnDqEyUDFXY="; };
                                        Chunky = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/fALzjamp/versions/mhLtMoLk/Chunky-Fabric-1.4.36.jar"; hash = "sha256-vLttrvBeviawvhMk2ZcjN5KecT4Qy+os4FEqMPYB77U="; };
                                        Spark = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/l6YH9Als/versions/NURCAL12/spark-1.10.128-fabric.jar"; hash = "sha256-EIgNMtuvsJZxaeW4i3V0QhF/TpGldt/aMlq9FXxf8Ug="; };
                                        Carpet = pkgs.fetchurl { url = "https://github.com/gnembon/fabric-carpet/releases/download/1.4.169/fabric-carpet-1.21.5-1.4.169+v250325.jar"; hash = "sha256-RQYsKAkSvlPjWih0RCRygKfxLkn165uaCPlNPPx8goE="; };
                                        #xyz = pkgs.fetchurl { url = ""; };
                                        });
                                };
                        };
                };
        };

        networking = {
                firewall = {
                        enable = true;
                };
        };

        system.stateVersion = "24.11";
}
