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

        environment.systemPackages = with pkgs; [
                tmux
        ];

        ##services.minecraft-servers = {
        ##        enable = true;
        ##        eula = true;
        ##        openFirewall = true;
        ##        managementSystem.systemd-socket.enable = true;
        ##        servers = {
        ##                cool-server1 = {
        ##                        enable = true;
        ##                        autoStart = true;
        ##                        package = pkgs.purpurServers.purpur-1_21_8;
        ##                        serverProperties = {
        ##                                motd = "Xerposcraft";
        ##                                difficulty = "hard";
        ##                                simulation-distance = 5;
        ##                                view-distance = 12;
        ##                                initial-enabled-packs = "vanilla,minecart_improvements";
        ##                                server-ip = "0.0.0.0";
        ##                                spawn-protection = 0;
        ##                                enforce-secure-profile = "false";
        ##                        };
##
        ##                        symlinks = {
        ##                                #"plugins/prism.jar" = prism;
        ##                                #"plugins/nbt-api.jar" = nbt-api;
        ##                                "plugins/luckperms.jar" = luckperms;
        ##                                "plugins/chunky.jar" = chunky;
        ##                                "plugins/viab.jar" = viab;
        ##                                "plugins/terraform.jar" = terraform;
        ##                                "plugins/teakstweaks.jar" = teakstweaks;
        ##                                "plugins/spark.jar" = spark;
        ##                                "plugins/lpc.jar" = lpc;
        ##                                "plugins/boundless.jar" = boundless;
        ##                                "plugins/ecbookplus.jar" = ecbookplus;
        ##                                "plugins/craftbook.jar" = craftbook;
        ##                                "plugins/we.jar" = worldedit;
        ##                                "plugins/elytrabind.jar" = elytrabind;
        ##                                "plugins/svc.jar" = svc;
        ##                                "plugins/freedom.jar" = freedom;
        ##                                "plugins/dynamicrp.jar" = dynrp;
        ##                                "plugins/ltab.jar" = ltab;
        ##                                "plugins/enchantio.jar" = ench;
        ##                                "plugins/grief.jar" = grief;
        ##                        };
##
        ##                        jvmOpts = "-XX:+UseZGC -XX:+ZGenerational -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -Xms14336M -Xmx14336M";
        ##                };
        ##        };
        ##};

        networking = {
                firewall = {
                        enable = true;
                        allowedTCPPorts = [ 24454 34456 80 443 ];
                        allowedUDPPorts = [ 24454 34456 80 443 ];
                };
        };

        system.stateVersion = "24.11";
}
