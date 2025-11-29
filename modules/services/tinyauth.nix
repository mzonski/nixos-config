{
  delib,
  pkgs,
  host,
  config,
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
  serviceName = "tinyauth";
in
module {
  name = "services.tinyauth";

  options = moduleOptions {
    enable = boolOption false;
    dataDir = strOption "/nas/database/${serviceName}";
    domain = strOption "https://auth.zonni.pl";
    port = intOption 8086;
  };

  myconfig.ifEnabled =
    { cfg, ... }:
    {
      homelab.reverse-proxy.${serviceName} = {
        port = cfg.port;
        subdomain = "auth";
        requireAuth = false;
        root = true;
        public = true;
      };
      user.groups = [ serviceName ];
      homelab.users.db = [ serviceName ];
      homelab.users.auth = [ serviceName ];
    };

  nixos.always.imports = [
    ./../../nixos-modules/tinyauth.nix
  ];

  nixos.ifEnabled =
    { myconfig, cfg, ... }:
    {
      users.users.${serviceName}.uid = 988;
      users.groups.${serviceName}.gid = 983;

      sops =
        let
          sopsConfig = {
            sopsFile = host.secretsFile;
            owner = serviceName;
            group = serviceName;
          };
        in
        {
          secrets.tinyauth_pocket_id_client_id = sopsConfig;
          secrets.tinyauth_pocket_id_client_secret = sopsConfig;
          templates.tinyauth-config = {
            inherit (sopsConfig) owner group;
            content = ''
              PROVIDERS_POCKETID_CLIENT_ID=${config.sops.placeholder.tinyauth_pocket_id_client_id}
              PROVIDERS_POCKETID_CLIENT_SECRET=${config.sops.placeholder.tinyauth_pocket_id_client_secret}
              PROVIDERS_GOOGLE_CLIENT_ID=${config.sops.placeholder.oidc_google_client_id}
              PROVIDERS_GOOGLE_CLIENT_SECRET=${config.sops.placeholder.oidc_google_secret}
            '';
          };
        };

      services.tinyauth = {
        enable = true;
        package = pkgs.local.tinyauth;
        inherit (cfg) dataDir;
        environmentFile = config.sops.templates.tinyauth-config.path;

        user = serviceName;
        group = serviceName;

        settings = {
          ADDRESS = "127.0.0.1";
          APP_TITLE = "Homelab";
          APP_URL = cfg.domain;
          DATABASE_PATH = "${cfg.dataDir}/tinyauth.db";
          DISABLE_ANALYTICS = true;
          LOG_LEVEL = "info";
          PORT = cfg.port;
          RESOURCES_DIR = "${cfg.dataDir}/resources";
          SECURE_COOKIE = false;

          PROVIDERS_POCKETID_AUTH_URL = "${myconfig.services.pocket-id.domain}/authorize";
          PROVIDERS_POCKETID_TOKEN_URL = "${myconfig.services.pocket-id.domain}/api/oidc/token";
          PROVIDERS_POCKETID_USER_INFO_URL = "${myconfig.services.pocket-id.domain}/api/oidc/userinfo";
          PROVIDERS_POCKETID_REDIRECT_URL = "${cfg.domain}/api/oauth/callback/pocketid";
          PROVIDERS_POCKETID_SCOPES = "openid email profile groups";
          PROVIDERS_POCKETID_NAME = "Passkey";
        };
      };
    };
}
