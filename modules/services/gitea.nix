{
  delib,
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
  serviceName = "gitea";
in
module {
  name = "services.gitea";

  options = moduleOptions {
    enable = boolOption false;
    dbDir = strOption "/nas/database/${serviceName}";
    uiPort = intOption 8084;
  };

  myconfig.ifEnabled =
    { cfg, ... }:
    {
      homelab.db.${serviceName} = {
        type = "postgres";
      };
      homelab.reverse-proxy.${serviceName} = {
        port = cfg.uiPort;
        subdomain = "git";
        requireAuth = false;
      };
      user.groups = [ serviceName ];
      homelab.users.db = [ serviceName ];
    };

  nixos.ifEnabled =
    { myconfig, cfg, ... }:
    {
      users.users.${serviceName}.uid = 990;
      users.groups.${serviceName}.gid = 985;

      sops =
        let
          sopsConfig = {
            sopsFile = host.secretsFile;
            owner = serviceName;
            group = serviceName;
          };
        in
        {
          secrets.gitea_camo_hmac = sopsConfig;
          # secrets.maxmind_license_key = sopsConfig;
        };

      services.gitea = {
        enable = true;
        stateDir = cfg.dbDir;
        user = serviceName;
        group = serviceName;
        database = {
          createDatabase = false;
          type = "postgres";
          socket = "/run/postgresql";
          host = "127.0.0.1";
          port = myconfig.services.postgres.port;
          name = serviceName;
          user = serviceName;
        };
        captcha.enable = false;
        dump.enable = false;
        lfs.enable = true;

        appName = "Homelab Git";
        camoHmacKeyFile = config.sops.secrets.gitea_camo_hmac.path;
        settings =
          let
            domain = "https://git.${host.name}.${myconfig.homelab.domain}/";
          in
          {
            repository = {
              DISABLE_HTTP_GIT = true;
              ACCESS_CONTROL_ALLOW_ORIGIN = domain;
              DEFAULT_REPO_UNITS = "repo.code,repo.actions";
            };
            "repository.pull-request" = {
              DEFAULT_MERGE_STYLE = "squash";
            };
            "repository.upload" = {
              ALLOWED_TYPES = "*/*";
            };
            "repository.release" = {
              ALLOWED_TYPES = "*/*";
            };
            cors = {
              ALLOW_DOMAIN = domain;
            };
            ui = {
              SHOW_USER_EMAIL = false;
            };
            "ui.meta" = {
              AUTHOR = "Homelab";
              DESCRIPTION = "Homelab Git";
            };
            server = {
              HTTP_PORT = cfg.uiPort;
              DOMAIN = "git.${host.name}.${myconfig.homelab.domain}";
              ROOT_URL = domain;
              SSH_PORT = 22;
              LANDING_PAGE = "login";
            };
            security = {
              INSTALL_LOCK = true;
            };

            service = {
              DISABLE_REGISTRATION = true;
              ENABLE_BASIC_AUTHENTICATION = false;
              ENABLE_PASSWORD_SIGNIN_FORM = false;

            };
            "service.explore" = {
              REQUIRE_SIGNIN_VIEW = true;
            };
            cron = {
              ENABLED = true;
              SCHEDULE = "0 4 * * 0";
            };
            i18n = {
              LANGS = "en-US,pl-PL";
              NAMES = "English,Polski";
            };
            other = {
              SHOW_FOOTER_VERSION = false;
              SHOW_FOOTER_TEMPLATE_LOAD_TIME = false;
              SHOW_FOOTER_POWERED_BY = false;
              ENABLE_SITEMAP = false;
              ENABLE_FEED = false;
            };
            api = {
              ENABLE_SWAGGER = false;
            };
          };
      };
    };
}
