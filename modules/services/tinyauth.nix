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
              TINYAUTH_OAUTH_PROVIDERS_POCKETID_CLIENTID=${config.sops.placeholder.tinyauth_pocket_id_client_id}
              TINYAUTH_OAUTH_PROVIDERS_POCKETID_CLIENTSECRET=${config.sops.placeholder.tinyauth_pocket_id_client_secret}
              TINYAUTH_OAUTH_PROVIDERS_GOOGLE_CLIENTID=${config.sops.placeholder.oidc_google_client_id}
              TINYAUTH_OAUTH_PROVIDERS_GOOGLE_CLIENTSECRET=${config.sops.placeholder.oidc_google_secret}
            '';
          };
        };
      systemd.services.tinyauth = {
        after = [ "zfs.target" ];
        requires = [ "zfs.target" ];
      };
      services.tinyauth = {
        enable = true;
        package = pkgs.local.tinyauth;
        inherit (cfg) dataDir;
        environmentFile = config.sops.templates.tinyauth-config.path;
        user = serviceName;
        group = serviceName;
        settings = {
          TINYAUTH_SERVER_ADDRESS = "127.0.0.1";
          TINYAUTH_SERVER_PORT = cfg.port;
          TINYAUTH_APPURL = cfg.domain;
          TINYAUTH_UI_TITLE = "Homelab";
          TINYAUTH_DATABASE_PATH = "${cfg.dataDir}/tinyauth.db";
          TINYAUTH_ANALYTICS_ENABLED = false;
          TINYAUTH_LOG_LEVEL = "info";
          TINYAUTH_RESOURCES_PATH = "${cfg.dataDir}/resources";
          TINYAUTH_AUTH_SECURECOOKIE = false;
          TINYAUTH_OAUTH_PROVIDERS_POCKETID_AUTHURL = "${myconfig.services.pocket-id.domain}/authorize";
          TINYAUTH_OAUTH_PROVIDERS_POCKETID_TOKENURL = "${myconfig.services.pocket-id.domain}/api/oidc/token";
          TINYAUTH_OAUTH_PROVIDERS_POCKETID_USERINFOURL = "${myconfig.services.pocket-id.domain}/api/oidc/userinfo";
          TINYAUTH_OAUTH_PROVIDERS_POCKETID_REDIRECTURL = "${cfg.domain}/api/oauth/callback/pocketid";
          TINYAUTH_OAUTH_PROVIDERS_POCKETID_SCOPES = "openid email profile groups";
          TINYAUTH_OAUTH_PROVIDERS_POCKETID_NAME = "Passkey";
        };
      };
    };
}
