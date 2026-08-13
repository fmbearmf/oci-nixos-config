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
  velocity-secret = "girard231203";
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
      proxyConfig = (pkgs.formats.toml { }).generate "FabricProxy-Lite.toml" {
        secret = velocity-secret;
      };

      serverJar = pkgs.fetchurl {
        url = "https://meta.fabricmc.net/v2/versions/loader/26.2/0.19.3/1.1.2/server/jar";
        hash = "sha256-MB+DqsNrI/K8ZMxYVg7fmFM8+qMOU68AK6lQx19BALQ=";
      };

      serverWrapper = pkgs.stdenv.mkDerivation {
        pname = "crucible-server";
        version = "1.9.4";
        dontUnpack = true;

        installPhase = ''
          mkdir -p $out/bin
          cat <<EOF > $out/bin/minecraft-server
          #!/bin/sh
          mkdir -p config
          cp -f ${proxyConfig} ./config/FabricProxy-Lite.toml
          chmod 644 ./config/FabricProxy-Lite.toml

          exec ${pkgs.openjdk25_headless}/bin/java \$@ -jar ${serverJar} nogui
          EOF
          chmod +x $out/bin/minecraft-server
        '';
      };
    in
    {
      enable = true;
      eula = true;
      package = serverWrapper;

      # https://exa.y2k.diy/garden/jvm-args/
      jvmOpts = "-Xms8G -Xmx8G -XX:+UseZGC -XX:+UseCompactObjectHeaders --enable-native-access=ALL-UNNAMED";

      declarative = true;
      whitelist = {
        mincaraft = "bd0381fd-a21c-4289-bdb7-24892bda8e47";
        Incspa = "bf68bf6c-d2b7-4bba-9c2d-e33280c0808e";
        # deco
        Alt_Deco = "497c7e82-fce4-4fcc-8a32-ef109b660493";
        # lobotomite
        DisgustedConure = "abd2ef19-2077-45a2-992b-62a4b03aa381";
        # john the great
        Oohapenny = "13906f4c-314e-445a-b80b-f487ee1a452a";
        # adam merlin
        swaggiestwizard = "7e460670-2aaf-4ecc-b3c7-a75cc6420eac";
        # dainis
        TalkTuahGamer = "83c6da84-4e67-42e0-9748-6fde6d5f74e1";
        # xertun
        Xertundra = "724af479-5b42-40fa-afc2-9817b9a79506";
        # hexxii
        Hexxii = "37672df8-ab41-469b-8d24-ae7981e5e04c";
        # roob
        roobs_circus = "0963788f-437a-40bb-b470-00ad8634165f";
        # ivy
        ivysleepy = "ac45e19d-c47c-4518-9641-090e7e6402ee";
        # soviet onion
        TheSovietOnion_ = "baafab83-297d-4ebe-a2cb-7c6a30754d76";
        # dillon
        GodOfBeans21 = "650201a4-08c4-4d02-a32f-3adf050d1ac0";
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
        server-port = 25566;
        motd = "Swag Mode: Enabled";
        difficulty = 2;
        max-players = 20;
        white-list = true;
        allow-cheats = true;
        allow-flight = true;
        sync-chunk-writes = false;
        enforce-secure-profile = false;

        resource-pack = "https://download.mc-packs.net/pack/de22d3c7754a3ccb5ca43a74b9184da4a82bedb6.zip";
        resource-pack-sha1 = "de22d3c7754a3ccb5ca43a74b9184da4a82bedb6";
        resource-pack-id = "2f259a2e-5807-4977-89a9-4040637c00dc";
        resource-pack-prompt = "{\"text\":\"It gives you the cool old textures.\", \"color\":\"red\"}";
        require-resource-pack = false;

        spawn-protection = 0;
      };
    };

  systemd.services.minecraft-server.preStart =
    let
      mods = [
        {
          src = pkgs.fetchurl {
            name = "FabricProxy-Lite.jar";
            url = "https://cdn.modrinth.com/data/8dI2tmqs/versions/CsEpiziv/FabricProxy-Lite-2.12.0.jar";
            hash = "sha256-3KDQVoWvqiXVVDcq0RjZC2sn+F3tk+bbC4XYIqopNCo=";
          };
          name = "FabricProxy-Lite.jar";
        }

        {
          src = pkgs.fetchurl {
            name = "ModernerBeta.jar";
            url = "https://cdn.modrinth.com/data/xkrdwmh2/versions/J3Nn73Eo/moderner-beta-fabric-5.0.0-alpha.2%2B26.2.jar";
            hash = "sha256-7Ef6F1/jrTQaxL7p/Ghv/t0N/dYPGIo1xg7hdY7g1uw=";
          };
          name = "ModernerBeta.jar";
        }

        {
          src = pkgs.fetchurl {
            name = "FerriteCore.jar";
            url = "https://cdn.modrinth.com/data/uXXizFIs/versions/d5ddUdiB/ferritecore-9.0.0-fabric.jar";
            hash = "sha256-ITlmxy7ZZ6zHOSvrKKhm+6MB/1a5l2wueAHC233mvyI=";
          };
          name = "FerriteCore.jar";
        }

        {
          src = pkgs.fetchurl {
            name = "Lithium.jar";
            url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/f7vZ0VWU/lithium-fabric-0.25.3%2Bmc26.2.jar";
            hash = "sha256-/d6S4jjoB1+JrX9wHyo9WFSviLqaZ2VxhKRAexBKxWM=";
          };
          name = "Lithium.jar";
        }

        {
          src = pkgs.fetchurl {
            name = "ModernFix.jar";
            url = "https://cdn.modrinth.com/data/TjSm1wrD/versions/TUWH6NZu/modernfix-5.27.19-build.1.jar";
            hash = "sha256-+dC4muUeRDZGbe1IxF/sNSizzKBXmcspg3zwroGgip0=";
          };
          name = "ModernFix.jar";
        }

        {
          src = pkgs.fetchurl {
            name = "Krypton.jar";
            url = "https://cdn.modrinth.com/data/fQEb0iXm/versions/5WeL0Nkz/krypton-0.3.1.jar";
            hash = "sha256-XqiQFWGXPSnlHnUUadUtkhAPNIq0YeEYb2cBLpNCDEg=";
          };
          name = "Krypton.jar";
        }

        {
          src = pkgs.fetchurl {
            name = "C2ME.jar";
            url = "https://cdn.modrinth.com/data/VSNURh3q/versions/HBLtzvqv/c2me-fabric-mc26.2-0.4.2-alpha.0.35.jar";
            hash = "sha256-RRu5ox8AUGkQSUZExmnWY9gJsYdQswKTkMnK6OfYL2k=";
          };
          name = "C2ME.jar";
        }

        {
          src = pkgs.fetchurl {
            name = "Clumps.jar";
            url = "https://cdn.modrinth.com/data/Wnxd13zP/versions/dEMopoOJ/Clumps-fabric-26.2-26.2.1.jar";
            hash = "sha256-3JVEGQq/tlo8ndxdrRUjyd/FpzI0T1KNkIuVCJQ5jow=";
          };
          name = "Clumps.jar";
        }

        {
          src = pkgs.fetchurl {
            name = "ScalableLux.jar";
            url = "https://cdn.modrinth.com/data/Ps1zyz6x/versions/EKLUURiy/ScalableLux-fabric-0.3.0-alpha.0.3-all.jar";
            hash = "sha256-jXbPJ1idzI4Ww0ugcJqe4hNM/NYLkIYvjL0gTqm2x8g=";
          };
          name = "ScalableLux.jar";
        }

        {
          src = pkgs.fetchurl {
            name = "Carpet.jar";
            url = "https://cdn.modrinth.com/data/TQTTVgYE/versions/bGrLxJ8v/fabric-carpet-26.2%2Bv260616.jar";
            hash = "sha256-9q2pEq9lyRU21LDYCt8mzEOCUyUt2vJZ8sZheuRxMRw=";
          };
          name = "Carpet.jar";
        }

        {
          src = pkgs.fetchurl {
            name = "Async.jar";
            url = "https://cdn.modrinth.com/data/vEC2jm6I/versions/T6OSY8vJ/async-fabric-0.2.4%2Balpha-26.2.jar";
            hash = "sha256-jwxhQlXTFddzcQjhSeuIVIxxBjuJmpfqvKDv/NtaZyk=";
          };
          name = "Async.jar";
        }

        {
          src = pkgs.fetchurl {
            name = "Paper-API.jar";
            url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/3gT0I5vt/fabric-api-0.156.0%2B26.2.jar";
            hash = "sha256-jeGNn2qKKlshIO+ei/+3nMm3WYnAwCLDnJ38G8Oimpk=";
          };
          name = "Paper-API.jar";
        }

        {
          src = pkgs.fetchurl {
            name = "NoChatReports.jar";
            url = "https://cdn.modrinth.com/data/qQyHxfxd/versions/uiY9tUaj/NoChatReports-FABRIC-26.2-v2.20.1.jar";
            hash = "sha256-dUzOHpmRPrP+et7VASyyOjPIT6tK7g+EC600eF9YHic=";
          };
          name = "NoChatReports.jar";
        }

        {
          src = pkgs.fetchurl {
            name = "ViaVersion.jar";
            url = "https://cdn.modrinth.com/data/P1OZGk5p/versions/N1tHqKId/ViaVersion-5.12.0-SNAPSHOT.jar";
            hash = "sha256-VU3lgr8+QzsMlg6IOs+aFltu5yQRdh98he8Q6rz2yvA=";
          };
          name = "ViaVersion.jar";
        }

        {
          src = pkgs.fetchurl {
            name = "ViaFabric.jar";
            url = "https://cdn.modrinth.com/data/YlKdE5VK/versions/qTp3MGwf/ViaFabric-0.4.21%2B176-26.x.jar";
            hash = "sha256-544bkSmdUTSnMYO8X70xCRDAWeI32sWWpSVGGrvAhTY=";
          };
          name = "ViaFabric.jar";
        }

        {
          src = pkgs.fetchurl {
            name = "ImmersiveOptimization.jar";
            url = "https://cdn.modrinth.com/data/vNZgQmjg/versions/ULXQkJab/immersive_optimization-fabric-26.2-0.2.0.jar";
            hash = "sha256-wt5YlUzA0gLdIr1NzWGY9fjTDY5cIjvLxj7W5udLvIE=";
          };
          name = "ImmersiveOptimization.jar";
        }

        {
          src = pkgs.fetchurl {
            name = "Image2Map.jar";
            url = "https://cdn.modrinth.com/data/13RpG7dA/versions/RKJFfwTN/image2map-0.14.0%2B26.2.jar";
            hash = "sha256-bLK8mCB7UqC+uCv6g53RsaYrrqYd5oGh2HW5ne4fjwE=";
          };
          name = "Image2Map.jar";
        }

        {
          src = pkgs.fetchurl {
            name = "Spark.jar";
            url = "https://cdn.modrinth.com/data/l6YH9Als/versions/iYFOl6lQ/spark-1.10.173-fabric.jar";
            hash = "sha256-B27SKI2yoFym6AYWFeGjHRkSzxsQZl5PCaF5TV25lDM=";
          };
          name = "Spark.jar";
        }

        # dependency
        {
          src = pkgs.fetchurl {
            name = "Balm.jar";
            url = "https://cdn.modrinth.com/data/MBAkmtvl/versions/ln6vafmE/balm-fabric-26.2-26.2.0.5.jar";
            hash = "sha256-jOPq9F3+Zxlt2Hnm8hJAN0+3edJSivJXW9UkClUl66I=";
          };
          name = "Balm.jar";
        }

        {
          src = pkgs.fetchurl {
            name = "NetherPortalFix.jar";
            url = "https://cdn.modrinth.com/data/nPZr02ET/versions/GQpccFqg/netherportalfix-fabric-26.2-26.2.0.1.jar";
            hash = "sha256-QRldtUNx8MQ8lesMlr8DQlxhwtSt9q6avTe7+8Ez4bs=";
          };
          name = "NetherPortalFix.jar";
        }

        {
          src = pkgs.fetchurl {
            name = "ShulkerBox.jar";
            url = "https://cdn.modrinth.com/data/e8mI328p/versions/xCwACdpT/quickrightclick-26.2.0-1.9.jar";
            hash = "sha256-h+dzZZGVMr04oAQjXFjhIgu8uuaA2KPSftLOLdvXgxs=";
          };
          name = "AdvShulkerBox.jar";
        }

        {
          src = pkgs.fetchurl {
            name = "Collective.jar";
            url = "https://cdn.modrinth.com/data/e0M1UDsY/versions/M75JwjyS/collective-26.2.0-8.39.jar";
            hash = "sha256-zgcEMjvAbTge0KpjAp/Nn3gokSDXDG6kqKbIz59O0mo=";
          };
          name = "Collective.jar";
        }

        {
          src = ../blob/swagcraft-0.2.3.jar;
          name = "Swagcraft.jar";
        }
      ];
    in
    ''
      mkdir -p ${config.services.minecraft-server.dataDir}/mods

      find ${config.services.minecraft-server.dataDir}/mods/ -type l -delete

      ${lib.concatMapStringsSep "\n" (
        mod: "ln -svf ${mod.src} ${config.services.minecraft-server.dataDir}/mods/${mod.name}"
      ) mods}
    '';

  users.users.velocity = {
    isSystemUser = true;
    group = "velocity";
    home = "/var/lib/velocity";
    createHome = true;
  };
  users.groups.velocity = { };

  systemd.sockets.velocity = {
    bindsTo = [ "velocity.service" ];
    socketConfig = {
      ListenFIFO = "/run/velocity.stdin";
      SocketMode = "0660";
      SocketUser = "velocity";
      SocketGroup = "velocity";
      RemoveOnStop = true;
      FlushPending = true;
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
          player-info-forwarding-mode = "modern";
          ping-passthrough = "all";

          servers = {
            survival = "127.0.0.1:25566";
            try = [
              "survival"
            ];
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
            enabled = true;
            port = 25565;
            map = "swagballs";
            show-plugins = false;
          };
        };

        "plugins/Reconnect.jar" = fetchurl {
          name = "Reconnect.jar";
          url = "https://github.com/fa1thl3ss/ProxyReconnect/releases/download/velocity/proxyreconnect-1.0.jar";
          hash = "sha256-xWtIrBrb4SPhwojWlQ4WINtdlJgE3NjuP8CH8l8NtVs=";
        };

        "plugins/LP.jar" = fetchurl {
          name = "LP.jar";
          url = "https://cdn.modrinth.com/data/Vebnzrzj/versions/BmxJvHsa/LuckPerms-Velocity-5.5.53.jar";
          hash = "sha256-P0iqr9DGsjYuAtwbdK2gu+V/JWLe9UUIvWSmYY5Ty6w=";
        };

        "plugins/Geyser-Velocity.jar" = fetchurl {
          name = "Geyser-Velocity.jar";
          url = "https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/velocity";
          hash = "sha256-XYvTgxk1+KWAVuZObuvCnNINtDzLsk6UAF1FwV+1Fig=";
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
      requires = [ "velocity.socket" ];
      after = [
        "network.target"
        "velocity.socket"
      ];
      wantedBy = [ "multi-user.target" ];

      preStart = ''
        echo "${velocity-secret}" > "${velocityRoot}/swagballs.secret"

      ''
      + lib.concatStringsSep "\n" (
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

        StandardInput = "socket";
        StandardOutput = "journal";
        StandardError = "journal";
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
