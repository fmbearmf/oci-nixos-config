# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "fatso"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;


  

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.bear = {
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBGbO4POGsK7m7ZfAet1XdP+KF+ICRsvKtubc28bBkzV1KKV+GL56orBeNP2sN74rbBrAtv3GUi+idCDN5cM6D6LQjsU5ccBg5UI0oD1W7lZUkC3ZOmvK7u6BTtySx+iCjOlp9uJy4Rs8TJnt0zUG4yLDQUgL8I1i2tUyKhlZ+g/dVo+NMTrExMbsCesa0iP/qgUygjbYh8+9CYdZjEv1+xePwlwn6rVqX0n7J5saSqhcizs5aBYv+q+awLDNUmh1C8fEuPSAmTzky30wTpksxj9sYfF+kD9qypOPWVa/5sCSAKB7pIVm4XyyBT2DpVRgPj3q/3VI9sTQoN0F0TlsatwJmE8eXRL8kT80JVJw6RafAfiHUtgAbKYs6pMqXNrOgak36HY8BsbW9yirepsaf4QcxkPosiWJ5NWogni9SZSLwCVT4JqEty+6QSrxFNbhitCo1tUmL6LBP/iYbjHsvg93MimxAlAiEha4Qv5o1fDYdnkZLYz4PwUPvDQta8Pc= bear@quantum"
    ];
    isNormalUser = true;
    hashedPassword = "$y$j9T$pDD1SWnLf8pWjFAkdxOsQ.$S4d9GI7QaprBBSg//iCycDbx4gYROVKjwQ.AieLpl/2";
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      nano
    ];
  };

  users.enforceIdUniqueness = true;
  users.mutableUsers = lib.mkForce false;
  users.motd = ''
_________________________
|                       |
|        _       _      |
|       | |     | |     |
|  _ __ | |_   _| |__   |
| | '_ \| | | | | '_ \  |
| | |_) | | |_| | | | | |
| | .__/|_|\__,_|_| |_| |
| | |                   |
| |_|                   |
| 		        |
|_______________________|
'';

  # programs.firefox.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
      LoginGraceTime = "120";
      MaxStartups = "100:30:200";
    };
  };
  services.fail2ban = {
    enable = true;
    maxretry = 5;
    ignoreIP = [
***REMOVED******REMOVED***      "172.16.0.0/12"
      "192.168.0.0/12"
    ];
    bantime = "24h";
    jails.sshd.settings = {
      mode = "aggressive";
    };
  };

  services.tailscale = {
    enable = true;
  };

  systemd.services.tailscale-autoconnect = {
    description = "idk";

    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig.Type = "oneshot";

    script = with pkgs; ''
	#wait
        sleep 2

        status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
	if [ $status = "Running" ]; then #nothing
	  exit 0
	fi

	#otherwise auth
	${tailscale}/bin/tailscale up --auth-key tskey-auth-kSiVd2iTgy11CNTRL-nJ5FQ72KDF7xMwhtFWvTF7QfXhcvQyirV --advertise-routes=192.168.0.0/16,169.254.169.254/32 --accept-dns=false
    '';
  };

  # Open ports in the firewall.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    allowedUDPPorts = [ config.services.tailscale.port ];
    trustedInterfaces = [ "tailscale0" ];
  };

  programs.mosh.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}

