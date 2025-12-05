{
  delib,
  pkgs,
  config,
  host,
  ...
}:
let
  inherit (delib)
    module
    moduleOptions
    boolOption
    strOption
    intOption
    ;
  serviceName = "pocket-id";
in
module {
  name = "services.pocket-id";

  options = moduleOptions {
    enable = boolOption false;
    dbDir = strOption "/nas/database/${serviceName}";
    port = intOption 8083;
    domain = strOption "https://oidc.zonni.pl";
  };

  myconfig.ifEnabled =
    { cfg, ... }:
    {
      homelab.db.${serviceName} = {
        type = "postgres";
      };
      homelab.reverse-proxy.${serviceName} = {
        port = cfg.port;
        subdomain = "oidc";
        requireAuth = false;
        root = true;
        public = true;
      };
      user.groups = [ serviceName ];
      homelab.users.db = [ serviceName ];
      homelab.users.auth = [ serviceName ];
    };

  nixos.always.imports = [
    ./../../nixos-modules/pocket-id-nixos.nix
  ];

  nixos.ifEnabled =
    { cfg, ... }:
    {
      users.users.${serviceName}.uid = 991;
      users.groups.${serviceName}.gid = 986;

      sops =
        let
          sopsConfig = {
            sopsFile = host.secretsFile;
            owner = serviceName;
            group = serviceName;
          };
        in
        {
          secrets.pocket_id_encryption_key = sopsConfig;
          secrets.maxmind_license_key = sopsConfig;
        };

      systemd.services.pocket-id = {
        after = [ "postgresql.service" ];
        requires = [ "postgresql.service" ];
      };

      services.pocket-id-nixos = {
        enable = true;
        package = pkgs.unstable.pocket-id;

        dataDir = cfg.dbDir;

        user = username;
        group = username;

        # https://pocket-id.org/docs/configuration/environment-variables#overriding-the-ui-configuration
        settings = {
          APP_URL = cfg.domain;
          TRUST_PROXY = true;

          MAXMIND_LICENSE_KEY_FILE = config.sops.secrets.maxmind_license_key.path;

          PUID = config.users.users.${serviceName}.uid;
          PGID = config.users.groups.${serviceName}.gid;

          DB_PROVIDER = "postgres";
          DB_CONNECTION_STRING = "postgres://pocket-id@/pocket-id";

          KEYS_STORAGE = "database";
          ENCRYPTION_KEY_FILE = config.sops.secrets.pocket_id_encryption_key.path;

          GEOLITE_DB_PATH = "${cfg.dbDir}/GeoLite2-City.mmdb";
          UPLOAD_PATH = "${cfg.dbDir}/uploads";

          PORT = cfg.port;
          HOST = "127.0.0.1";

          ANALYTICS_DISABLED = true;
          UI_CONFIG_DISABLED = false;

          # UI CONFIG OPTIONS
          ALLOW_USER_SIGNUPS = "disabled";

          APP_NAME = "Homelab OIDC";
        };
      };
    };
}
