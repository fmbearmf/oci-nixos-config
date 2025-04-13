{ config, lib, pkgs, inputs, ... }:

{
        virtualisation.containers.enable = true;

        containers.minecraft = {
                autoStart = true;
                privateNetwork = false;
                bindMounts = {
                        "/srv" = {
                                hostPath = "/mnt/containers/mc";
                                isReadOnly = false;
                        };
                };
                config = { config, pkgs, ... }@args: (import ./mc-container.nix) (args // { inputs = inputs; });
        };
}
