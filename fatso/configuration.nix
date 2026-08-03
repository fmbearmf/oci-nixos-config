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
      spigotConfig = (pkgs.formats.yaml { }).generate "spigot.yml" {
        config-version = 8;
        settings = {
          save-user-cache-on-stop-only = false;
          sample-count = 12;
          player-shuffle = 0;
          filter-creative-items = true;
          user-cache-size = 1000;
          int-cache-limit = 1024;
          moved-wrongly-threshold = 0.5;
          moved-too-quickly-multiplier = 100.0;
          timeout-time = 60;
          restart-on-crash = false;
          restart-script = "./start.sh";
          netty-threads = 4;

          attribute = {
            maxHealth.max = 2048.0;
            movementSpeed.max = 2048.0;
            attackDamage.max = 2048.0;
          };

          global-api-cache = false;
          bungeecord = true;
          late-bind = false;
          debug = false;
        };
        commands = {
          tab-complete = 0;
          spam-exclusions = [ "/skill" ];
          silent-commandblock-console = false;
          replace-commands = [
            "setblock"
            "summon"
            "testforblock"
            "tellraw"
          ];
          log = true;
        };
        messages = {
          whitelist = "You are not whitelisted!";
          unknown-command = "Unknown command. Type \"/help\" for help";
          server-full = "The server is full!";
          outdated-client = "Outdated client! Use {0}";
          outdated-server = "Outdated server! I'm still on {0}";
          restart = "Server is restarting!! Literally 1984.";
        };
        stats = {
          disable-saving = false;
          forced-stats = { };
        };
        world-settings = {
          default = {
            verbose = true;
            nerf-spawner-mobs = false;
            anti-xray = {
              enabled = false;
              engine-mode = 1;
              hide-blocks = [
                14
                15
                16
                21
                48
                49
                54
                56
                73
                74
                82
                129
                130
              ];
              replace-blocks = [
                1
                5
              ];
            };
            mob-spawn-range = 4;
            growth = {
              cactus-modifier = 100;
              cane-modifier = 100;
              melon-modifier = 100;
              mushroom-modifier = 100;
              pumpkin-modifier = 100;
              sapling-modifier = 100;
              wheat-modifier = 100;
            };
            entity-activation-range = {
              animals = 32;
              monsters = 32;
              misc = 16;
            };
            entity-tracking-range = {
              players = 128;
              animals = 48;
              monsters = 32;
              misc = 32;
              other = 64;
            };
            hopper-alt-ticking = false;
            ticks-per = {
              hopper-transfer = 8;
              hopper-check = 8;
            };
            hopper-amount = 1;
            random-light-updates = false;
            save-structure-info = true;
            max-bulk-chunks = 5;
            max-entity-collisions = 8;
            dragon-death-sound-radius = 0;
            seed-village = 10387312;
            seed-feature = 14357617;
            hunger = {
              walk-exhaustion = 0.15;
              sprint-exhaustion = 0.6;
              combat-exhaustion = 0.2;
              regen-exhaustion = 2.5;
            };
            max-tnt-per-tick = 10;
            view-distance = 10;
            chunks-per-tick = 650;
            clear-tick-list = false;
            merge-radius = {
              exp = 4.0;
              item = 2.5;
            };
            item-despawn-rate = 6000;
            arrow-despawn-rate = 1200;
            enable-zombie-pigmen-portal-spawns = false;
            wither-spawn-sound-radius = 0;
            hanging-tick-frequency = 100;
            zombie-aggressive-towards-villager = true;
          };
        };
      };

      serverJar = pkgs.fetchurl {
        url = "https://github.com/sarabveer/CraftBukkit-Spigot-Binary/raw/refs/heads/master/spigot-1.7.10-1.8-R0.1/spigot-1.7.10-1.8-R0.1-1656.jar";
        hash = "sha256-e1DglMIQiHU7QcX9KpqKmVOQjNDub6Cz3t9R949hKS0=";
      };
      serverWrapper = pkgs.stdenv.mkDerivation {
        pname = "crucible-server";
        version = "1.7.10";
        dontUnpack = true;

        installPhase = ''
          mkdir -p $out/bin
          cat <<EOF > $out/bin/minecraft-server
          #!/bin/sh
          cp -f ${spigotConfig} ./spigot.yml
          chmod 644 ./spigot.yml

          exec ${pkgs.openjdk8_headless}/bin/java \$@ -jar ${serverJar} nogui
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
      package = serverWrapper;

      # https://exa.y2k.diy/garden/jvm-args/
      jvmOpts = "-Dlog4j.configurationFile=${log4ShellMitigator} -Xms2G -Xmx6G -XX:+UseG1GC";

      declarative = true;
      whitelist = {
        mincaraft = "bd0381fd-a21c-4289-bdb7-24892bda8e47";
        Incspa = "bf68bf6c-d2b7-4bba-9c2d-e33280c0808e";
        # deco
        Alt_Deco = "497c7e82-fce4-4fcc-8a32-ef109b660493";
        # lobotomite
        DisgustedConure = "abd2ef19-2077-45a2-992b-62a4b03aa381";
        # incspa bedrock
        ".Shrek12346" = "00000000-0000-0000-0009-01f0e45556f7";
        # oscar bedrock
        ".GoldArdeo4669" = "00000000-0000-0000-0009-01f401ac62d8";
        # ren bedrock
        ".BerserkBlader303" = "00000000-0000-0000-0009-01f04099d1b2";
      };
      serverProperties = {
        online-mode = false;
        server-ip = "127.0.0.1";
        server-port = 25567;
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

  users.users.velocity = {
    isSystemUser = true;
    group = "velocity";
    home = "/var/lib/velocity";
    createHome = true;
  };
  users.groups.velocity = { };

  users.users.viaproxy = {
    isSystemUser = true;
    group = "viaproxy";
    home = "/var/lib/viaproxy";
    createHome = true;
  };
  users.groups.viaproxy = { };

  systemd.services.viaproxy =
    let
      vpRoot = config.users.users.viaproxy.home;

      inherit (pkgs) lib fetchurl formats;

      yamlFormat = formats.yaml { };

      vpJar = fetchurl {
        name = "ViaProxy.jar";
        url = "https://github.com/ViaVersion/ViaProxy/releases/download/v3.4.12/ViaProxy-3.4.12.jar";
        hash = "sha256-Ms6a2HGusDKGgjwp2iYuvXWZKGTnhX2yg/EDUlx/wMs=";
      };

      files = {
        "viaproxy.yml" = yamlFormat.generate "viaproxy.yml" {
          bind-address = "127.0.0.1:25566";
          target-address = "127.0.0.1:25567";
          target-version = 5;
          connection-timeout = 8000;
          proxy-online-mode = false;
          auth-method = "NONE";
          minecraft-account-index = 0;
          betacraft-auth = false;
          backend-proxy-url = "";
          backend-haproxy = false;
          frontend-haproxy = false;
          chat-signing = false;
          compression-threshold = 256;
          allow-beta-pinging = false;
          ignore-protocol-translation-errors = false;
          suppress-client-protocol-errors = false;
          allow-legacy-client-passthrough = false;
          bungeecord-player-info-passthrough = true;
          rewrite-handshake-packet = true;
          rewrite-transfer-packets = true;
          custom-motd = "";
          custom-favicon-path = "";
          resource-pack-url = "";
          wildcard-domain-handling = "NONE";
          simple-voice-chat-support = false;
          fix-fabric-particle-api = true;
          fake-accept-resource-packs = false;
          skip-config-state-packet-queue = false;
          log-ips = false;
          log-client-status-requests = false;
        };
      };
    in
    {
      description = "viaproxy";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      preStart = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (relPath: src: ''
          mkdir -p "${vpRoot}/${dirOf relPath}"
          cp -vf ${src} "${vpRoot}/${relPath}"
          chmod 644 "${vpRoot}/${relPath}"
        '') files
      );

      serviceConfig = {
        Type = "simple";
        User = "viaproxy";
        Group = "viaproxy";
        StateDirectory = "viaproxy";
        WorkingDirectory = vpRoot;
        ExecStart = "${pkgs.jdk25_headless}/bin/java -Xms512M -Xmx1024M -jar ${vpJar} config viaproxy.yml";
        Restart = "always";
        RestartSec = "10s";
      };
    };

  systemd.services.velocity =
    let
      velocityRoot = config.users.users.velocity.home;

      inherit (pkgs) lib fetchurl formats;

      tomlFormat = formats.toml { };
      yamlFormat = formats.yaml { };

      velocityJar = fetchurl {
        name = "Velocity-Server.jar";
        url = "https://fill-data.papermc.io/v1/objects/d94545b4fc9a7a7b7eae3e29999b1882f9ca3b5b30873b173d84199d3b84039b/velocity-4.1.0-SNAPSHOT-14.jar";
        hash = "sha256-2UVFtPyaent+rj4pmZsYgvnKO1swhzsXPYQZnTuEA5s=";
      };

      files = {
        "velocity.toml" = tomlFormat.generate "velocity.toml" {
          config-version = "2.8";
          bind = "0.0.0.0:25565";
          motd = "Swag Mode: Enabled";
          show-max-players = 30;
          online-mode = true;

          prevent-client-proxy-connections = false;

          forwarding-secret-file = "swagballs.secret";
          kick-existing-players = false;
          player-info-forwarding-mode = "legacy";
          ping-passthrough = "all";

          servers = {
            backend1710 = "127.0.0.1:25566";
            try = [ "backend1710" ];
          };

          forced-hosts = { };

          advanced = {
            compression-threshold = 256;
            compression-level = -1;
            login-ratelimit = 1000;
            connection-timeout = 5000;
            read-timeout = 30000;
            haproxy-protocol = false;
            tcp-fast-open = true;
            bungee-plugin-message-channel = true;
            show-ping-requests = false;
            failover-on-unexpected-server-disconnect = true;
            announce-proxy-commands = true;
            log-command-executions = false;
            log-player-connections = true;
            accepts-transfers = false;
            enable-reuse-port = true;
            command-rate-limit = 100;
            forward-commands-if-rate-limited = true;
            kick-after-rate-limited-commands = 0;
            tab-complete-rate-limit = 10;
            kick-after-rate-limited-tab-completes = 0;
          };

          query = {
            enabled = false;
            port = 25565;
            map = "swagballs";
            show-plugins = false;
          };
        };

        "plugins/Geyser-Velocity.jar" = fetchurl {
          name = "Geyser-Velocity.jar";
          url = "https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/velocity";
          hash = "sha256-OzMvOqWpOs8B9WaMkPNusxd7bXaRAZzc6jyj6XeRLBw=";
        };

        "plugins/Floodgate-Velocity.jar" = fetchurl {
          name = "Floodgate-Geyser.jar";
          url = "https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/velocity";
          hash = "sha256-UkdExcPeZ99LhK3IC6u/XZ8AQSwaWT90qK5ubd6SwG8=";
        };

        "plugins/Geyser-Velocity/config.yml" = yamlFormat.generate "geyser-config.yml" {
          bedrock = {
            address = "0.0.0.0";
            port = 19132;
            clone-remote-port = false;
          };
          java.auth-type = "floodgate";
          motd = {
            primary-motd = "";
            secondary-motd = "";
            passthrough-motd = true;
            max-players = 100;
            passthrough-player-counts = true;
            integrated-ping-passthrough = true;
            ping-passthrough-interval = 3;
          };
          gameplay = {
            server-name = "Swagballs";
            cooldown-type = "disabled";
            command-suggestions = false;
            show-coordinates = true;
            disable-bedrock-scaffolding = true;
            nether-roof-workaround = false;
            emotes-enabled = true;
            block-legacy-codes = true;
            unusable-space-block = "minecraft:barrier";
            enable-custom-content = true;
            force-resource-packs = true;
            enabled-integrated-pack = true;
            forward-player-ping = false;
            xbox-achievements-enabled = false;
            max-visible-custom-skulls = 128;
            custom-skull-render-distance = 32;
          };

          default-locale = "system";
          log-player-ip-addresses = true;
          saved-user-logins = [ "ASOIDAsdioaiowjdaowidjioasi232193" ];
          pending-authentication-timeout = 120;
          notify-on-new-bedrock-update = true;

          debug-mode = false;
          config-version = 7;

          advanced = {
            cache-images = 0;
            scoreboard-packet-threshold = 20;
            add-team-suggestions = true;
            resource-pack-urls = [ ];
            floodgate-key-file = "key.pem";
            java = {
              use-haproxy-protocol = false;
              use-direct-connection = true;
              disable-compression = true;
            };
            bedrock = {
              broadcast-port = 0;
              compression-level = 4;
              use-haproxy-protocol = false;
              haproxy-protocol-whitelisted-ips = [ ];
              use-waterdogpe-forwarding = false;
              mtu = 1400;
              validate-bedrock-login = true;
            };
          };
        };

        "plugins/floodgate/config.yml" = yamlFormat.generate "floodgate-config.yml" {
          key-file-name = "key.pem";
          username-prefix = ".";
          replace-spaces = true;
          send-floodgate-data = false;

          disconnect = {
            invalid-key = "invalid-key; Ping lord.foog.the.2st. if you see this.";
            invalid-arguments-length = "Expected {} arguments, got {}. Is geyser up-to-date?";
          };

          player-link = {
            enabled = true;
            require-link = false;
            enabled-own-linking = false;
            allowed = true;
            link-code-timeout = 600;
            type = "sqlite";
            enable-global-linking = true;
          };

          metrics = {
            enabled = false;
            uuid = "7f6287ff-6f2e-423d-ac82-20b48abc7e27";
          };

          config-version = 3;
        };
      };
    in
    {
      description = "velocity mc proxy";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      preStart = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (relPath: src: ''
          mkdir -p "${velocityRoot}/${dirOf relPath}"
          cp -vf ${src} "${velocityRoot}/${relPath}"
          chmod 644 "${velocityRoot}/${relPath}"
        '') files
      );

      serviceConfig = {
        Type = "simple";
        User = "velocity";
        Group = "velocity";
        StateDirectory = "velocity";
        WorkingDirectory = velocityRoot;
        ExecStart = "${pkgs.jdk25_headless}/bin/java -Xms512M -Xmx1024M -jar ${velocityJar}";
        Restart = "always";
        RestartSec = "10s";
      };
    };

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
