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
  username = "gitea";
in
module {
  name = "services.gitea";

  options = moduleOptions {
    enable = boolOption false;
    dbDir = strOption "/nas/database/${username}";
    uiPort = intOption 8084;
    sshClonePort = intOption 2222;
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
        settings = {
          server = {
            HTTP_PORT = cfg.uiPort;
            DOMAIN = "git.${host.name}.${myconfig.homelab.domain}";
            ROOT_URL = "https://git.${host.name}.${myconfig.homelab.domain}/";
            # STATIC_ROOT_PATH <- check via repl
            SSH_PORT = cfg.sshClonePort;
          };
          other = {
            SHOW_FOOTER_VERSION = false;
          };

          service.DISABLE_REGISTRATION = true;
          # session.COOKIE_SECURE = true;
        };
      };
    };
}
