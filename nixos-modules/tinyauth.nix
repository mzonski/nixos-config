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
        TINYAUTH_AUTH_USERS=admin:$$2a$$10$$...
        TINYAUTH_OAUTH_PROVIDERS_GOOGLE_CLIENTSECRET=your-secret
      '';
      default = null;
      example = "/var/lib/secrets/tinyauth";
    };

    settings = mkOption {
      type = submodule {
        freeformType = format.type;

        options = {
          # General Configuration
          TINYAUTH_APPURL = mkOption {
            type = str;
            description = ''
              The base URL where the app is hosted.
            '';
            example = "https://auth.example.com";
          };

          # Database Configuration
          TINYAUTH_DATABASE_PATH = mkOption {
            type = path;
            description = ''
              The path to the database, including file name.
            '';
            default = "/var/lib/tinyauth/tinyauth.db";
          };

          # Analytics Configuration
          TINYAUTH_ANALYTICS_ENABLED = mkOption {
            type = bool;
            description = ''
              Enable periodic anonymous version information collection (heartbeat).

              When enabled, Tinyauth sends anonymous version information every 12 hours
              to get insights on usage. The collected information includes:
              - Tinyauth version
              - Instance UUID (generated with UUID v4 from the app URL)
              - Time of the request
            '';
            default = true;
          };

          # Resources Configuration
          TINYAUTH_RESOURCES_ENABLED = mkOption {
            type = bool;
            description = ''
              Enable the resources server.
            '';
            default = true;
          };

          TINYAUTH_RESOURCES_PATH = mkOption {
            type = path;
            description = ''
              The directory where resources are stored (e.g., background image).
            '';
            default = "/var/lib/tinyauth/resources";
          };

          # Server Configuration
          TINYAUTH_SERVER_PORT = mkOption {
            type = port;
            description = ''
              The port on which the server listens.
            '';
            default = 3000;
          };

          TINYAUTH_SERVER_ADDRESS = mkOption {
            type = str;
            description = ''
              The address on which the server listens.
            '';
            default = "0.0.0.0";
          };

          TINYAUTH_SERVER_SOCKETPATH = mkOption {
            type = str;
            description = ''
              The path to the Unix socket. Leave empty to disable.
            '';
            default = "";
          };

          # Authentication Configuration
          TINYAUTH_AUTH_IP_ALLOW = mkOption {
            type = str;
            description = ''
              List of allowed IPs or CIDR ranges (global).
            '';
            default = "";
          };

          TINYAUTH_AUTH_IP_BLOCK = mkOption {
            type = str;
            description = ''
              List of blocked IPs or CIDR ranges (global).
            '';
            default = "";
          };

          TINYAUTH_AUTH_USERS = mkOption {
            type = str;
            description = ''
              Comma-separated list of users (username:hashed_password).
            '';
            default = "";
          };

          TINYAUTH_AUTH_USERSFILE = mkOption {
            type = str;
            description = ''
              Path to the users file.
            '';
            default = "";
          };

          TINYAUTH_AUTH_SECURECOOKIE = mkOption {
            type = bool;
            description = ''
              Enable secure cookies (send cookie over secure connection only).
            '';
            default = false;
          };

          TINYAUTH_AUTH_SESSIONEXPIRY = mkOption {
            type = int;
            description = ''
              Session expiry time in seconds.
            '';
            default = 86400;
          };

          TINYAUTH_AUTH_SESSIONMAXLIFETIME = mkOption {
            type = int;
            description = ''
              Maximum session lifetime in seconds (0 to disable).
            '';
            default = 0;
          };

          TINYAUTH_AUTH_LOGINTIMEOUT = mkOption {
            type = int;
            description = ''
              Login timeout in seconds after max retries reached (0 to disable).
            '';
            default = 300;
          };

          TINYAUTH_AUTH_LOGINMAXRETRIES = mkOption {
            type = int;
            description = ''
              Maximum login retries before timeout (0 to disable).
            '';
            default = 3;
          };

          TINYAUTH_AUTH_TRUSTEDPROXIES = mkOption {
            type = str;
            description = ''
              Comma-separated list of trusted proxy addresses
              for correct client IP detection.
            '';
            default = "";
            example = "10.0.0.0/8,172.16.0.0/12,192.168.0.0/16";
          };

          # ACLs Configuration
          #
          # Per-app access control lists are dynamic and use the freeformType
          # to allow arbitrary TINYAUTH_APPS_[NAME]_* keys. Examples:
          #
          #   TINYAUTH_APPS_MYAPP_CONFIG_DOMAIN = "myapp.example.com";
          #   TINYAUTH_APPS_MYAPP_USERS_ALLOW = "alice,bob";
          #   TINYAUTH_APPS_MYAPP_USERS_BLOCK = "eve";
          #   TINYAUTH_APPS_MYAPP_OAUTH_WHITELIST = "group1";
          #   TINYAUTH_APPS_MYAPP_OAUTH_GROUPS = "admins";
          #   TINYAUTH_APPS_MYAPP_IP_ALLOW = "10.0.0.0/8";
          #   TINYAUTH_APPS_MYAPP_IP_BLOCK = "192.168.1.1";
          #   TINYAUTH_APPS_MYAPP_IP_BYPASS = "172.16.0.0/12";
          #   TINYAUTH_APPS_MYAPP_RESPONSE_HEADERS = "X-Custom: value";
          #   TINYAUTH_APPS_MYAPP_RESPONSE_BASICAUTH_USERNAME = "user";
          #   TINYAUTH_APPS_MYAPP_RESPONSE_BASICAUTH_PASSWORD = "pass";
          #   TINYAUTH_APPS_MYAPP_RESPONSE_BASICAUTH_PASSWORDFILE = "/run/secrets/pass";
          #   TINYAUTH_APPS_MYAPP_PATH_ALLOW = "/public,/health";
          #   TINYAUTH_APPS_MYAPP_PATH_BLOCK = "/admin";
          #   TINYAUTH_APPS_MYAPP_LDAP_GROUPS = "cn=admins,ou=groups,dc=example,dc=com";
          #
          # These are handled by the freeformType and do not need explicit
          # option declarations.

          # OAuth Configuration
          TINYAUTH_OAUTH_WHITELIST = mkOption {
            type = str;
            description = ''
              Comma-separated list of allowed OAuth domains.
            '';
            default = "";
            example = "user@example.com,admin@example.com";
          };

          TINYAUTH_OAUTH_AUTOREDIRECT = mkOption {
            type = str;
            description = ''
              The OAuth provider to use for automatic redirection.
            '';
            default = "";
            example = "google";
          };

          # Per-provider OAuth settings are dynamic and use the freeformType
          # to allow arbitrary TINYAUTH_OAUTH_PROVIDERS_[NAME]_* keys.
          # Examples:
          #
          #   TINYAUTH_OAUTH_PROVIDERS_GOOGLE_CLIENTID = "...";
          #   TINYAUTH_OAUTH_PROVIDERS_GOOGLE_CLIENTSECRET = "...";
          #   TINYAUTH_OAUTH_PROVIDERS_GOOGLE_CLIENTSECRETFILE = "/run/secrets/oauth";
          #   TINYAUTH_OAUTH_PROVIDERS_GOOGLE_SCOPES = "openid,email,profile";
          #   TINYAUTH_OAUTH_PROVIDERS_GOOGLE_REDIRECTURL = "https://auth.example.com/callback";
          #   TINYAUTH_OAUTH_PROVIDERS_GOOGLE_AUTHURL = "https://...";
          #   TINYAUTH_OAUTH_PROVIDERS_GOOGLE_TOKENURL = "https://...";
          #   TINYAUTH_OAUTH_PROVIDERS_GOOGLE_USERINFOURL = "https://...";
          #   TINYAUTH_OAUTH_PROVIDERS_GOOGLE_INSECURE = false;
          #   TINYAUTH_OAUTH_PROVIDERS_GOOGLE_NAME = "Google";
          #
          # Note: Using "google" or "github" as provider names triggers
          # automatic filling of auth URLs and scopes. You only need to
          # provide the client ID and secret.

          # OIDC Configuration
          TINYAUTH_OIDC_PRIVATEKEYPATH = mkOption {
            type = path;
            description = ''
              Path to the private key file, including file name.
            '';
            default = "/var/lib/tinyauth/tinyauth_oidc_key";
          };

          TINYAUTH_OIDC_PUBLICKEYPATH = mkOption {
            type = path;
            description = ''
              Path to the public key file, including file name.
            '';
            default = "/var/lib/tinyauth/tinyauth_oidc_key.pub";
          };

          # Per-client OIDC settings are dynamic and use the freeformType
          # to allow arbitrary TINYAUTH_OIDC_CLIENTS_[NAME]_* keys.
          # Examples:
          #
          #   TINYAUTH_OIDC_CLIENTS_MYAPP_CLIENTID = "...";
          #   TINYAUTH_OIDC_CLIENTS_MYAPP_CLIENTSECRET = "...";
          #   TINYAUTH_OIDC_CLIENTS_MYAPP_CLIENTSECRETFILE = "/run/secrets/oidc";
          #   TINYAUTH_OIDC_CLIENTS_MYAPP_TRUSTEDREDIRECTURIS = "https://app.example.com/callback";
          #   TINYAUTH_OIDC_CLIENTS_MYAPP_NAME = "My App";

          # UI Configuration
          TINYAUTH_UI_TITLE = mkOption {
            type = str;
            description = ''
              The title of the UI.
            '';
            default = "Tinyauth";
          };

          TINYAUTH_UI_FORGOTPASSWORDMESSAGE = mkOption {
            type = str;
            description = ''
              Message displayed on the forgot password page.
            '';
            default = "You can change your password by changing the configuration.";
          };

          TINYAUTH_UI_BACKGROUNDIMAGE = mkOption {
            type = str;
            description = ''
              Path to the background image.
            '';
            default = "/background.jpg";
          };

          TINYAUTH_UI_WARNINGSENABLED = mkOption {
            type = bool;
            description = ''
              Enable UI warnings.
            '';
            default = true;
          };

          # LDAP Configuration
          TINYAUTH_LDAP_ADDRESS = mkOption {
            type = str;
            description = ''
              LDAP server address.
            '';
            default = "";
            example = "ldaps://ldap.example.com:636";
          };

          TINYAUTH_LDAP_BINDDN = mkOption {
            type = str;
            description = ''
              Bind DN for LDAP authentication.
            '';
            default = "";
            example = "cn=admin,dc=example,dc=com";
          };

          TINYAUTH_LDAP_BINDPASSWORD = mkOption {
            type = str;
            description = ''
              Bind password for LDAP authentication.
            '';
            default = "";
          };

          TINYAUTH_LDAP_BASEDN = mkOption {
            type = str;
            description = ''
              Base DN for LDAP searches.
            '';
            default = "";
            example = "dc=example,dc=com";
          };

          TINYAUTH_LDAP_INSECURE = mkOption {
            type = bool;
            description = ''
              Allow insecure LDAP connections.
            '';
            default = false;
          };

          TINYAUTH_LDAP_SEARCHFILTER = mkOption {
            type = str;
            description = ''
              LDAP search filter.

              Note: For Windows LDAP, use: (&(sAMAccountName=%s))
            '';
            default = "(uid=%s)";
          };

          TINYAUTH_LDAP_AUTHCERT = mkOption {
            type = str;
            description = ''
              Certificate for mTLS authentication.
            '';
            default = "";
          };

          TINYAUTH_LDAP_AUTHKEY = mkOption {
            type = str;
            description = ''
              Certificate key for mTLS authentication.
            '';
            default = "";
          };

          TINYAUTH_LDAP_GROUPCACHETTL = mkOption {
            type = int;
            description = ''
              Cache duration for LDAP group membership in seconds.
            '';
            default = 900;
          };

          # Logging Configuration
          TINYAUTH_LOG_LEVEL = mkOption {
            type = enum [
              "trace"
              "debug"
              "info"
              "warn"
              "error"
            ];
            description = ''
              Log level for the application.

              Note: The `trace` log level will log sensitive information such as
              usernames, emails and access controls. Use with caution.
            '';
            default = "info";
          };

          TINYAUTH_LOG_JSON = mkOption {
            type = bool;
            description = ''
              Enable JSON formatted logs.
            '';
            default = false;
          };

          TINYAUTH_LOG_STREAMS_HTTP_ENABLED = mkOption {
            type = bool;
            description = ''
              Enable the HTTP log stream.
            '';
            default = true;
          };

          TINYAUTH_LOG_STREAMS_HTTP_LEVEL = mkOption {
            type = str;
            description = ''
              Log level for the HTTP stream. Leave empty to use global level.
            '';
            default = "";
          };

          TINYAUTH_LOG_STREAMS_APP_ENABLED = mkOption {
            type = bool;
            description = ''
              Enable the app log stream.
            '';
            default = true;
          };

          TINYAUTH_LOG_STREAMS_APP_LEVEL = mkOption {
            type = str;
            description = ''
              Log level for the app stream. Leave empty to use global level.
            '';
            default = "";
          };

          TINYAUTH_LOG_STREAMS_AUDIT_ENABLED = mkOption {
            type = bool;
            description = ''
              Enable the audit log stream.
            '';
            default = false;
          };

          TINYAUTH_LOG_STREAMS_AUDIT_LEVEL = mkOption {
            type = enum [
              ""
              "trace"
              "debug"
              "info"
              "warn"
              "error"
            ];
            description = ''
              Log level for the audit stream. Leave empty to use global level.
            '';
            default = "";
          };
        };
      };

      default = { };

      description = ''
        Environment variables that will be passed to Tinyauth.

        See the [configuration documentation](https://tinyauth.app/docs/configuration)
        for supported values.

        Note: Sensitive values like TINYAUTH_AUTH_USERS and OAuth client secrets
        should be provided via `environmentFile` instead.
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
      optional (cfg.settings ? TINYAUTH_AUTH_USERS && cfg.settings.TINYAUTH_AUTH_USERS != "")
        "config.services.tinyauth.settings.TINYAUTH_AUTH_USERS will be stored as plaintext in the Nix store. Use config.services.tinyauth.environmentFile instead."
      ++
        optional (cfg.settings ? TINYAUTH_AUTH_USERSFILE && cfg.settings.TINYAUTH_AUTH_USERSFILE != "")
          "config.services.tinyauth.settings.TINYAUTH_AUTH_USERSFILE will be stored as plaintext in the Nix store. Use config.services.tinyauth.environmentFile instead."
      ++
        optional
          (cfg.settings ? TINYAUTH_LDAP_BINDPASSWORD && cfg.settings.TINYAUTH_LDAP_BINDPASSWORD != "")
          "config.services.tinyauth.settings.TINYAUTH_LDAP_BINDPASSWORD will be stored as plaintext in the Nix store. Use config.services.tinyauth.environmentFile instead."
      ++
        optional
          (builtins.any (
            name: lib.hasPrefix "TINYAUTH_OAUTH_PROVIDERS_" name && lib.hasSuffix "_CLIENTSECRET" name
          ) (builtins.attrNames cfg.settings))
          "OAuth client secrets in config.services.tinyauth.settings will be stored as plaintext in the Nix store. Use config.services.tinyauth.environmentFile instead."
      ++
        optional
          (builtins.any (
            name: lib.hasPrefix "TINYAUTH_OIDC_CLIENTS_" name && lib.hasSuffix "_CLIENTSECRET" name
          ) (builtins.attrNames cfg.settings))
          "OIDC client secrets in config.services.tinyauth.settings will be stored as plaintext in the Nix store. Use config.services.tinyauth.environmentFile instead.";

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 ${cfg.user} ${cfg.group}"
      "d ${cfg.settings.TINYAUTH_RESOURCES_PATH} 0755 ${cfg.user} ${cfg.group}"
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
