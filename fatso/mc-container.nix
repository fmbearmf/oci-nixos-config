{ config, pkgs, inputs, lib, ... }:

let
        prism = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/oLV8Vvxy/versions/oObLE6w4/prism-paper-v4.0-beta1.jar"; hash = "sha256-57iXGPlGeSe3szXQ5rWl6cqbXrAxs/qjFAS/ZziWj4I="; };
        nbt-api = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/nfGCP9fk/versions/DwUuYPlT/item-nbt-api-plugin-2.15.0.jar"; hash = "sha256-pfWT1iFLjf951dMEs6gTFgg2vksLcU8eD3mp4N4LnuE="; };
        luckperms = pkgs.fetchurl { url = "https://download.luckperms.net/1581/bukkit/loader/LuckPerms-Bukkit-5.4.164.jar"; hash = "sha256-Tidn8/dlSdRVK/+5CyY9nRmadFQg9JnqiPV0k/jQtPU="; };
        chunky = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/fALzjamp/versions/SmZRkQyR/Chunky-Bukkit-1.4.36.jar"; hash = "sha256-rbTvPqm3j7xIP017rcSdgPm/Pglp7aRltUPBM2hMObQ="; };
        viab = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/IAvnm8Mq/versions/UKjQOr3g/VillagerInABukkit-paper-1.1.2.jar"; hash = "sha256-feyt/3apeBYpPyWDDcwepw/F8LsFuPk1LaT1Rz7cKrE="; };
        terraform = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/8JQgYY94/versions/YwK17sJ8/TerraformGenerator-19.1.1.jar"; hash = "sha256-dt6kNKNZvOtAU0te0hNkmgWwhnlVeMztu+IlZ/k/XiY="; };
        teakstweaks = pkgs.fetchurl { url = "https://hangarcdn.papermc.io/plugins/teakivy/TeaksTweaks/versions/2.0.8-mc1.21.5/PAPER/TeaksTweaks-v2.0.8-mc1.21.5.jar"; hash = "sha256-eWy+4VzESET8oIB/0UPtzv847MWZJ5QiguS4TiegdGk="; };
        spark = pkgs.fetchurl { url = "https://ci.lucko.me/job/spark/485/artifact/spark-bukkit/build/libs/spark-1.10.136-bukkit.jar"; hash = "sha256-c1i9g3zAXFTsCknFobK0RfT2nqXKC+F4ShzkplmrM6o="; };

        armorenchants = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/ldjV6Y1m/versions/coeCQtAp/Compatible%20Protection%20Enchantments%20v2.1%201.21%20-%201.21.3.zip"; hash = "sha256-Uxi3P8N/67NDwc4X0P4XgaFIR0f3zEj1WC8EIxwDBzE="; };
        lpc = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/LOlAU5yB/versions/qppjVMZp/LPC-Minimessage.jar"; hash = "sha256-F/ba0wgUJaHO+/D7Teak6h2HHF0am2mlcih1awynxq0="; };
in
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

        environment.systemPackages = with pkgs; [
                tmux
        ];

        services.minecraft-servers = {
                enable = true;
                eula = true;
                openFirewall = true;
                managementSystem.systemd-socket.enable = true;
                servers = {
                        cool-server1 = {
                                enable = true;
                                autoStart = true;
                                package = pkgs.paperServers.paper-1_21_5;
                                serverProperties = {
                                        motd = "Xerpos Extreme Survival";
                                        difficulty = "hard";
                                        simulation-distance = 5;
                                        view-distance = 12;
                                        initial-enabled-packs = "vanilla,minecart_improvements";
                                        server-ip = "0.0.0.0";
                                        spawn-protection = 0;
                                };

                                symlinks = {
                                        "plugins/prism.jar" = prism;
                                        "plugins/nbt-api.jar" = nbt-api;
                                        "plugins/luckperms.jar" = luckperms;
                                        "plugins/chunky.jar" = chunky;
                                        "plugins/viab.jar" = viab;
                                        "plugins/terraform.jar" = terraform;
                                        "plugins/teakstweaks.jar" = teakstweaks;
                                        "plugins/spark.jar" = spark;
                                        "plugins/lpc.jar" = lpc;
                                };

                                files = {
                                        "world/datapacks/armorenchants.zip" = armorenchants;
                                };

                                jvmOpts = "-XX:+UseZGC -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -Xms6144M -Xmx6144M";
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
