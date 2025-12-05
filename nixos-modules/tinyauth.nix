{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib)
    concatStringsSep
    getExe
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    optional
    optionalAttrs
    ;
  inherit (lib.types)
    bool
    enum
    int
    nullOr
    path
    port
    str
    submodule
    ;

  cfg = config.services.tinyauth;

  format = pkgs.formats.keyValue { };
  settingsFile = format.generate "tinyauth-env-vars" cfg.settings;
in
{
  options.services.tinyauth = {
    enable = mkEnableOption "Tinyauth server";

    package = mkPackageOption pkgs "tinyauth" { };

    environmentFile = mkOption {
      type = nullOr path;
      description = ''
        Path to an environment file loaded for the Tinyauth service.

        This can be used to securely store tokens and secrets outside of the world-readable Nix store.

        Example contents of the file:
        USERS=admin:$$2a$$10$$...
        PROVIDERS_GOOGLE_CLIENT_SECRET=your-secret
      '';
      default = null;
      example = "/var/lib/secrets/tinyauth";
    };

    settings = mkOption {
      type = submodule {
        freeformType = format.type;

        options = {
          ADDRESS = mkOption {
            type = str;
            description = ''
              Address to bind the server to.
            '';
            default = "0.0.0.0";
          };

          PORT = mkOption {
            type = port;
            description = ''
              Port to run the server on.
            '';
            default = 3000;
          };

          APP_URL = mkOption {
            type = str;
            description = ''
              The Tinyauth URL. This is required.
            '';
            example = "https://auth.example.com";
          };

          APP_TITLE = mkOption {
            type = str;
            description = ''
              Title of the app.
            '';
            default = "Tinyauth";
          };

          DATABASE_PATH = mkOption {
            type = path;
            description = ''
              Path to the SQLite database file.
            '';
            default = "/var/lib/tinyauth/tinyauth.db";
          };

          LOG_LEVEL = mkOption {
            type = enum [
              "trace"
              "debug"
              "info"
              "warn"
              "error"
              "fatal"
              "panic"
            ];
            description = ''
              Log level for the application.

              Note: The `trace` log level will log sensitive information such as
              usernames, emails and access controls. Use with caution.
            '';
            default = "info";
          };

          DISABLE_ANALYTICS = mkOption {
            type = bool;
            description = ''
              Disable anonymous version collection (heartbeat).

              When enabled, Tinyauth sends anonymous version information every 12 hours
              to get insights on usage. The collected information includes:
              - Tinyauth version
              - Instance UUID (generated with UUID v4 from the app URL)
              - Time of the request
            '';
            default = false;
          };

          DISABLE_RESOURCES = mkOption {
            type = bool;
            description = ''
              Disable the resources server.
            '';
            default = false;
          };

          RESOURCES_DIR = mkOption {
            type = path;
            description = ''
              Path to a directory containing custom resources (e.g., background image).
            '';
            default = "/var/lib/tinyauth/resources";
          };

          BACKGROUND_IMAGE = mkOption {
            type = str;
            description = ''
              Background image URL for the login page.
            '';
            default = "/background.jpg";
          };

          SECURE_COOKIE = mkOption {
            type = bool;
            description = ''
              Send cookie over secure connection only.
            '';
            default = false;
          };

          SESSION_EXPIRY = mkOption {
            type = int;
            description = ''
              Session (cookie) expiration time in seconds.
            '';
            default = 86400;
          };

          LOGIN_MAX_RETRIES = mkOption {
            type = int;
            description = ''
              Maximum login attempts before timeout (0 to disable).
            '';
            default = 5;
          };

          LOGIN_TIMEOUT = mkOption {
            type = int;
            description = ''
              Login timeout in seconds after max retries reached (0 to disable).
            '';
            default = 300;
          };

          FORGOT_PASSWORD_MESSAGE = mkOption {
            type = str;
            description = ''
              Message to show on the forgot password page.
            '';
            default = "";
          };

          TRUSTED_PROXIES = mkOption {
            type = str;
            description = ''
              Comma-separated list of trusted proxies (IP addresses or CIDRs)
              for correct client IP detection.
            '';
            default = "";
            example = "10.0.0.0/8,172.16.0.0/12,192.168.0.0/16";
          };

          OAUTH_AUTO_REDIRECT = mkOption {
            type = str;
            description = ''
              Auto redirect to the specified OAuth provider.
            '';
            default = "";
            example = "google";
          };

          OAUTH_WHITELIST = mkOption {
            type = str;
            description = ''
              Comma-separated list of email addresses to whitelist when using OAuth.
            '';
            default = "";
            example = "user@example.com,admin@example.com";
          };
        };
      };

      default = { };

      description = ''
        Environment variables that will be passed to Tinyauth.

        See the [configuration documentation](https://tinyauth.app/docs/configuration)
        for supported values.

        Note: Sensitive values like USERS and OAuth client secrets should be
        provided via `environmentFile` instead.
      '';
    };

    dataDir = mkOption {
      type = path;
      default = "/var/lib/tinyauth";
      description = ''
        The directory where Tinyauth will store its data, such as the database and resources.
      '';
    };

    user = mkOption {
      type = str;
      default = "tinyauth";
      description = "User account under which Tinyauth runs.";
    };

    group = mkOption {
      type = str;
      default = "tinyauth";
      description = "Group account under which Tinyauth runs.";
    };
  };

  config = mkIf cfg.enable {
    warnings =
      optional (cfg.settings ? USERS)
        "config.services.tinyauth.settings.USERS will be stored as plaintext in the Nix store. Use config.services.tinyauth.environmentFile instead."
      ++
        optional (cfg.settings ? USERS_FILE)
          "config.services.tinyauth.settings.USERS_FILE will be stored as plaintext in the Nix store. Use config.services.tinyauth.environmentFile instead."
      ++
        optional
          (builtins.any (name: lib.hasPrefix "PROVIDERS_" name && lib.hasSuffix "_CLIENT_SECRET" name) (
            builtins.attrNames cfg.settings
          ))
          "OAuth client secrets in config.services.tinyauth.settings will be stored as plaintext in the Nix store. Use config.services.tinyauth.environmentFile instead.";

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 ${cfg.user} ${cfg.group}"
      "d ${cfg.settings.RESOURCES_DIR} 0755 ${cfg.user} ${cfg.group}"
    ];

    systemd.services = {
      tinyauth = {
        description = "Tinyauth";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        restartTriggers = [
          cfg.package
          settingsFile
        ]
        ++ optional (cfg.environmentFile != null) cfg.environmentFile;

        serviceConfig = {
          Type = "simple";
          User = cfg.user;
          Group = cfg.group;
          WorkingDirectory = cfg.dataDir;
          ExecStart = getExe cfg.package;
          Restart = "always";
          EnvironmentFile = [ settingsFile ] ++ optional (cfg.environmentFile != null) cfg.environmentFile;
          SyslogIdentifier = "tinyauth";

          # Hardening
          AmbientCapabilities = "";
          CapabilityBoundingSet = "";
          DeviceAllow = "";
          DevicePolicy = "closed";
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateNetwork = false; # provides the service through network
          PrivateTmp = true;
          PrivateUsers = true;
          ProcSubset = "pid";
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "strict";
          ReadWritePaths = [ cfg.dataDir ];
          # ReadPaths = [ "/nix/store/ja2sqp0bqvkf7q5wp0jp24sbd11cdwa2-tinyauth-4.0.1/bin/tinyauth" ];
          RemoveIPC = true;
          RestrictAddressFamilies = [
            "AF_UNIX"
            "AF_INET"
            "AF_INET6"
          ];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";
          SystemCallFilter = concatStringsSep " " [
            "~"
            "@clock"
            "@cpu-emulation"
            "@debug"
            "@module"
            "@mount"
            "@obsolete"
            "@privileged"
            "@raw-io"
            "@reboot"
            "@resources"
            "@swap"
          ];
          UMask = "0077";
        };
      };
    };

    users.users = optionalAttrs (cfg.user == "tinyauth") {
      tinyauth = {
        isSystemUser = true;
        group = cfg.group;
        description = "Tinyauth user";
        home = cfg.dataDir;
      };
    };

    users.groups = optionalAttrs (cfg.group == "tinyauth") {
      tinyauth = { };
    };
  };
}
