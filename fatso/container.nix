{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  virtualisation.containers.enable = false;

  containers.minecraft = {
    autoStart = false;
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
