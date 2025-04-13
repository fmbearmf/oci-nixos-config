# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/profiles/qemu-guest.nix")
    ];

  boot.initrd.availableKernelModules = [ "virtio_scsi" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/ebec7f46-1aff-4e35-b544-88d99ad912dc";
      fsType = "btrfs";
      options = [ "subvol=@root" "compress-force=zstd:2" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/19ED-EF44";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/ebec7f46-1aff-4e35-b544-88d99ad912dc";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/ebec7f46-1aff-4e35-b544-88d99ad912dc";
      fsType = "btrfs";
      options = [ "subvol=@nix" "compress-force=zstd:2" ];
    };

  fileSystems."/mnt/containers" =
    { device = "/dev/disk/by-uuid/812143ff-5c07-4141-b443-168c1ac1b65b";
      fsType = "btrfs";
      options = [ "subvol=@containers" "compress-force=lzo" ];
    };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eth0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
