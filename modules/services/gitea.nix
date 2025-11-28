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
  username = "gitea";
in
module {
  name = "services.gitea";

  options = moduleOptions {
    enable = boolOption false;
    dbDir = strOption "/nas/database/${username}";
    uiPort = intOption 8084;
    sshClonePort = intOption 22;
  };

  myconfig.ifEnabled =
    { cfg, ... }:
    {
      homelab.db.${username} = {
        type = "postgres";
      };
      homelab.reverse-proxy.${username} = {
        port = cfg.uiPort;
        subdomain = "git";
        requireAuth = false;
      };
      user.groups = [ username ];
    };

  nixos.ifEnabled =
    { myconfig, cfg, ... }:
    let
      userId = 990;
      groupId = 985;
    in
    {
      networking.firewall.allowedTCPPorts = [ cfg.sshClonePort ];
      sops =
        let
          sopsConfig = {
            sopsFile = host.secretsFile;
            owner = username;
            group = username;
          };
        in
        {
          secrets.gitea_camo_hmac = sopsConfig;
          # secrets.maxmind_license_key = sopsConfig;
        };
      users.users.${username} = {
        group = username;
        extraGroups = [ "db" ];
        uid = userId;
      };
      users.groups.${username}.gid = groupId;

      services.gitea = {
        enable = true;
        stateDir = cfg.dbDir;
        user = username;
        group = username;
        database = {
          createDatabase = false;
          type = "postgres";
          socket = "/run/postgresql";
          host = "127.0.0.1";
          port = myconfig.services.postgres.port;
          name = username;
          user = username;
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
              SSH_PORT = cfg.sshClonePort;
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
