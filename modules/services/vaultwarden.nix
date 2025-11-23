{
  delib,
  config,
  host,
  pkgs,
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
  serviceName = "vaultwarden";
in
module {
  name = "services.vaultwarden";

  options = moduleOptions {
    enable = boolOption false;
    serviceDir = strOption "/nas/database/${serviceName}";
    uiPort = intOption 8085;
  };

  myconfig.ifEnabled =
    { cfg, ... }:
    {
      homelab.db.${serviceName} = {
        type = "postgres";
      };
      homelab.reverse-proxy.${serviceName} = {
        port = cfg.uiPort;
        subdomain = "vault";
      };
      user.groups = [ serviceName ];
    };

  nixos.ifEnabled =
    { myconfig, cfg, ... }:
    let
      userId = 989;
      groupId = 984;
    in
    {
      sops =
        let
          sopsConfig = {
            sopsFile = host.secretsFile;
            owner = serviceName;
            group = serviceName;
          };
        in
        {
          secrets.vaultwarden_admin_token = sopsConfig;
          secrets.vaultwarden_installation_id = sopsConfig;
          secrets.vaultwarden_installation_key = sopsConfig;
          secrets.yubikey_client_id = sopsConfig;
          secrets.yubikey_secret_key = sopsConfig;
          secrets.smtp_host = sopsConfig;
          secrets.smtp_username = sopsConfig;
          secrets.smtp_password = sopsConfig;
          templates.vaultwarden_env = {
            content = ''
              ADMIN_TOKEN=${config.sops.placeholder.vaultwarden_admin_token}
              PUSH_INSTALLATION_ID=${config.sops.placeholder.vaultwarden_installation_id}
              PUSH_INSTALLATION_KEY=${config.sops.placeholder.vaultwarden_installation_key}
              YUBICO_CLIENT_ID=${config.sops.placeholder.yubikey_client_id}
              YUBICO_SECRET_KEY=${config.sops.placeholder.yubikey_secret_key}
              SMTP_HOST=${config.sops.placeholder.smtp_host}
              SMTP_FROM=${config.sops.placeholder.smtp_username}
              SMTP_USERNAME=${config.sops.placeholder.smtp_username}
              SMTP_PASSWORD=${config.sops.placeholder.smtp_password}
            '';
            owner = serviceName;
            group = serviceName;
          };
        };
      users.users.${serviceName} = {
        group = serviceName;
        extraGroups = [ "db" ];
        uid = userId;
      };
      users.groups.${serviceName}.gid = groupId;

      systemd.services.vaultwarden.serviceConfig = {
        ReadWritePaths = [ cfg.serviceDir ];
        ReadOnlyPaths = [ config.sops.templates.vaultwarden_env.path ];
      };

      # https://discourse.nixos.org/t/nullmailer-and-systemd-services/41225/5
      services.vaultwarden = {
        enable = true;
        package = pkgs.unstable.vaultwarden-postgresql;
        dbBackend = "postgresql";
        environmentFile = config.sops.templates.vaultwarden_env.path;
        config = {
          DOMAIN = "https://vault.${host.name}.${myconfig.homelab.domain}";

          SIGNUPS_ALLOWED = false;
          # LOG_LEVEL = "debug";

          ROCKET_ADDRESS = "127.0.0.1";
          ROCKET_PORT = cfg.uiPort;
          DATABASE_URL = "postgres://${serviceName}@/${serviceName}";

          YUBICO_SERVER = "https://api.yubico.com/wsapi/2.0/verify";

          DATA_FOLDER = "${cfg.serviceDir}/data";
          TMP_FOLDER = "${cfg.serviceDir}/tmp";
          TEMPLATES_FOLDER = "${cfg.serviceDir}/templates";
          RSA_KEY_FILENAME = "${cfg.serviceDir}/rsa_key";

          PUSH_ENABLED = true;
          PUSH_RELAY_URI = "https://api.bitwarden.eu";
          PUSH_IDENTITY_URI = "https://identity.bitwarden.eu";

          INVITATION_ORG_NAME = "Homelab Vault";
          SMTP_FROM_NAME = "Homelab Vault";
        };
      };
    };
}
