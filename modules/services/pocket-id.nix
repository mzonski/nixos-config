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
  username = "pocket-id";
in
module {
  name = "services.pocket-id";

  options = moduleOptions {
    enable = boolOption false;
    dbDir = strOption "/nas/database/${username}";
    port = intOption 8083;
  };

  myconfig.ifEnabled =
    { cfg, ... }:
    {
      homelab.db.${username} = {
        type = "postgres";
      };
      homelab.reverse-proxy.${username} = {
        port = cfg.port;
        subdomain = "auth";
      };
      user.groups = [ username ];
    };

  nixos.ifEnabled =
    { myconfig, cfg, ... }:
    let
      userId = 991;
      groupId = 986;
    in

    {

      sops =
        let
          sopsConfig = {
            sopsFile = host.secretsFile;
            owner = username;
            group = username;
          };
        in
        {
          secrets.pocket_id_encryption_key = sopsConfig;
          secrets.maxmind_license_key = sopsConfig;
        };
      users.users.${username} = {
        extraGroups = [ "db" ];
        uid = userId;
      };
      users.groups.${username}.gid = groupId;

      services.pocket-id-nixos = {
        enable = true;
        package = pkgs.unstable.pocket-id;

        dataDir = cfg.dbDir;

        user = username;
        group = username;

        # https://pocket-id.org/docs/configuration/environment-variables#overriding-the-ui-configuration
        settings = {
          APP_URL = "https://auth.${host.name}.${myconfig.homelab.domain}/";
          TRUST_PROXY = true;

          MAXMIND_LICENSE_KEY_FILE = config.sops.secrets.maxmind_license_key.path;

          PUID = userId;
          PGID = groupId;

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

          APP_NAME = "Homelab Auth";
        };
      };
    };
}
