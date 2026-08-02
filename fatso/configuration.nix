# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  wikiHost = "wiki.bear.oops.wtf";
  inherit (inputs.nix-minecraft.lib) collectFilesAt;
  cloudflareIpv4 = pkgs.fetchurl {
    url = "https://www.cloudflare.com/ips-v4";
    hash = "sha256-8Cxtg7wBqwroV3Fg4DbXAMdFU1m84FTfiE5dfZ5Onns=";
  };
  cloudflareIpv6 = pkgs.fetchurl {
    url = "https://www.cloudflare.com/ips-v6";
    hash = "sha256-np054+g7rQDE3sr9U8Y/piAp89ldto3pN9K+KCNMoKk=";
  };
  cloudflareIps = lib.filter (ip: ip != "") (
    lib.splitString "\n" (
      (builtins.readFile cloudflareIpv4) + "\n" + (builtins.readFile cloudflareIpv6)
    )
  );
  realIpConfig = ''
    ${lib.concatMapStrings (ip: "set_real_ip_from ${ip};\n") cloudflareIps}
    real_ip_header CF-Connecting-IP;
  '';
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.nix-minecraft.nixosModules.minecraft-servers
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "fatso"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager = {
    enable = true;
  };

  systemd.services.NetworkManager-wait-online.enable = false;

  #systemd.services.gamblepert = {
  #  description = "election bot";
  #  wantedBy = [ "multi-user.target" ];
  #  confinement.enable = true;
  #  enable = true;
  #  serviceConfig = {
  #    Type = "simple";
  #    User = "bear";
  #    Group = "users";
  #    ProtectSystem = "full";
  #    ProtectHome = true;
  #    NoNewPrivileges = true;
  #    ExecStart = "${inputs.gamblepert.defaultPackage.aarch64-linux}/bin/gamblepert";
  #  };
  #};

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
  #
  services.minecraft-server =
    let
      crucibleJar = pkgs.fetchurl {
        url = "https://github.com/sarabveer/CraftBukkit-Spigot-Binary/raw/refs/heads/master/spigot-1.7.10-1.8-R0.1/spigot-1.7.10-1.8-R0.1-1656.jar";
        hash = "sha256-e1DglMIQiHU7QcX9KpqKmVOQjNDub6Cz3t9R949hKS0=";
      };
      crucibleServer = pkgs.stdenv.mkDerivation {
        pname = "crucible-server";
        version = "1.7.10";
        dontUnpack = true;

        installPhase = ''
          mkdir -p $out/bin
          cat <<EOF > $out/bin/minecraft-server
          #!/bin/sh
          exec ${pkgs.openjdk8_headless}/bin/java \$JVMOPTS -jar ${crucibleJar} nogui
          EOF
          chmod +x $out/bin/minecraft-server
        '';
      };
      log4ShellMitigator = pkgs.fetchurl {
        url = "https://launcher.mojang.com/v1/objects/4bb89a97a66f350bc9f73b3ca8509632682aea2e/log4j2_17-111.xml";
        hash = "sha256-wE6xWjtrDMVkKkOXk8KVFySRqG2jTBdkA3UvrGG6/XI=";
      };
    in
    {
      enable = true;
      eula = true;
      package = crucibleServer;

      # https://exa.y2k.diy/garden/jvm-args/
      jvmOpts = "-Dlog4j.configurationFile=${log4ShellMitigator} -Xms2G -Xmx6G -XX:+UseG1GC";

      declarative = true;
      whitelist = {
        mincaraft = "bd0381fd-a21c-4289-bdb7-24892bda8e47";
      };
      serverProperties = {
        server-port = 25565;
        motd = "Swag Mode: Enabled";
        difficulty = 2;
        max-players = 20;
        white-list = true;
        allow-cheats = true;
      };
    };

  systemd.services.minecraft-server.preStart =
    let
      plugins = [
        (pkgs.fetchurl {
          name = "WorldEdit-6.1.9.jar";
          url = "https://cdn.modrinth.com/data/1u6JkXh5/versions/JezAXbj7/worldedit-bukkit-6.1.9.jar";
          hash = "sha256-WnuI9vdbSgtu/UeuA+nCaiA27NEisDpFymNd3jhtYYY=";
        })
        (pkgs.fetchurl {
          name = "CraftBook-3.8.9.jar";
          url = "https://cdn.modrinth.com/data/jrO7z7l7/versions/bhFLT0vN/CraftBook_3.8.9.jar";
          hash = "sha256-8roKjhtan1WPXEcUvytgE/QoK3/HHbtvdHUWZ1dBaKs=";
        })
      ];
    in
    ''
      mkdir -p ${config.services.minecraft-server.dataDir}/plugins

      find ${config.services.minecraft-server.dataDir}/plugins/ -type l -delete

      ${lib.concatMapStringsSep "\n" (
        plugin: "ln -sf ${plugin} ${config.services.minecraft-server.dataDir}/plugins/${plugin.name}"
      ) plugins}
    '';

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
    | |_|  x                |
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
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = false;
      LoginGraceTime = "120";
      MaxStartups = "100:30:200";
    };

    extraConfig = ''
      Match Address 100.64.0.0/10
        PermitRootLogin yes
    '';
  };
  services.fail2ban = {
    enable = true;
    maxretry = 5;
    ignoreIP = [
      "172.16.0.0/12"
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

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "melchi@garfias.org";

  services.mediawiki = {
    enable = true;
    name = "Xertuncord Cinematic Universe";
    nginx = {
      hostName = wikiHost;
    };
    webserver = "nginx";
    passwordFile = pkgs.writeText "password" "swagmapassword332";
    extraConfig = ''
      $wgEnableEmail = true;
      $wgEmailConfirmToEdit = true;
      $wgAllowHTMLEmail = true;
      $wgSMTP = [
        "host" => "smtp.email.us-phoenix-1.oci.oraclecloud.com",
        "IDHost" => "wiki.bear.oops.wtf",
        "localhost" => "wiki.bear.oops.wtf",
        "port" => 587,
        "auth" => true,
        "username" => "ocid1.user.oc1..aaaaaaaa4b2pofjvlxqht3kgnsp2hylvfr3lpghxvlrlwcp6qudvhc4wyyua@ocid1.tenancy.oc1..aaaaaaaa6roop4fnvqoko5xlh24i5dtxa7wq6zie5ezh35su2c772gk63swq.41.com",
        "password" => "y]F.38+sW9{]O.<VFz-&"
      ];
      $wgPasswordSender = "rugiverse@wiki.bear.oops.wtf";
      $wgUserEmailConfirmationTokenExpiry = 240;
      $wgNewPasswordExpiry = 240;
    '';
    url = "https://${wikiHost}";
    extensions = {
      VisualEditor = null;
      CodeEditor = null;
      WikiEditor = null;
      Cite = null;
      CiteThisPage = null;
      CategoryTree = null;
      TemplateStyles = null;
    };
  };

  services.gembox = {
    enable = true;
  };

  services.nginx = {
    enable = true;

    virtualHosts."${wikiHost}" = {
      enableACME = true;
      forceSSL = true;
    };

    virtualHosts."backend.bear.oops.wtf" = {
      enableACME = true;
      forceSSL = true;
    };

    virtualHosts."gembox.dev" = {
      extraConfig = realIpConfig;
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://unix:${config.services.gembox.socketPath}:/";
      };
    };
  };

  mailserver = {
    enable = true;
    fqdn = "backend.bear.oops.wtf";
    domains = [ "bear.oops.wtf" ];

    accounts = {
      "bear@bear.oops.wtf" = {
        hashedPassword = "$2b$05$.Fl7sF4Ab6nXlqC/mxhqbOYPvA233NBrFQB2XRpEionfmEczfQo2e";
        aliases = [ "admin@bear.oops.wtf" ];
      };
    };

    x509.useACMEHost = "backend.bear.oops.wtf";
    stateVersion = 3;
  };

  services.postfix = {
    enable = true;
    #domain = "bear.oops.wtf";
    #origin = "bear.oops.wtf";
    #hostname = "backend.bear.oops.wtf";
    #relayHost = "[smtp.email.us-phoenix-1.oci.oraclecloud.com]:587";
    #relayPort = 587;
    settings.main = {
      #relay_domains = [ "hash:/var/lib/mailman/data/postfix_domains" ];
      #transport_maps = [ "hash:/var/lib/mailman/data/postfix_lmtp" ];
      #local_recipient_maps = [ "hash:/var/lib/mailman/data/postfix_lmtp" ];
      relayhost = [ "[smtp.email.us-phoenix-1.oci.oraclecloud.com]:587" ];
      smtp_sasl_password_maps = "static:ocid1.user.oc1..aaaaaaaa4b2pofjvlxqht3kgnsp2hylvfr3lpghxvlrlwcp6qudvhc4wyyua@ocid1.tenancy.oc1..aaaaaaaa6roop4fnvqoko5xlh24i5dtxa7wq6zie5ezh35su2c772gk63swq.41.com:y]F.38+sW9{]O.<VFz-&";
      smtp_sasl_auth_enable = "yes";
      smtp_sasl_security_options = "noanonymous";
      #smtp_tls_security_level = "may";
      local_header_rewrite_clients = "static:all";
      append_dot_mydomain = "yes";
    };
    #extraConfig = ''
    #  smtp_sasl_auth_enable = yes
    #  local_header_rewrite_clients = static:all
    #  append_dot_mydomain = yes
    #'';
  };

  services.roundcube = {
    enable = true;
    hostName = "backend.bear.oops.wtf";
    extraConfig = ''
      $config['smtp_host'] = "tls://${config.mailserver.fqdn}";
      $config['smtp_user'] = "%u";
      $config['smtp_pass'] = "%p";

      $config['default_host'] = "ssl://${config.mailserver.fqdn}:993";
      $config['default_port'] = 993;
    '';

  };

  networking.extraHosts = ''
    127.0.0.1 backend.bear.oops.wtf
  '';

  services.dovecot2 = {
    enable = true;
    settings.protocols = {
      imap = true;
    };
  };

  systemd.services.tailscale-autoconnect = {
    description = "idk";

    after = [
      "network-pre.target"
      "tailscale.service"
    ];
    wants = [
      "network-pre.target"
      "tailscale.service"
    ];
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
      	${tailscale}/bin/tailscale up --auth-key tskey-auth-kbKqVNEMJf11CNTRL-XcqaNcxBaDMzvoTGPqhTCMbjK6HdK9tL --advertise-routes=192.168.0.0/16,169.254.169.254/32 --accept-dns=false
    '';
  };

  # Open ports in the firewall.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      25565
      24454
      19132
      34456
      80
      443
      25
      587
      465
      993
    ];
    allowedUDPPorts = [
      config.services.tailscale.port
      24454
      19132
      34456
      80
      443
    ];
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
