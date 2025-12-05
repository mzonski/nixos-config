{
  delib,
  config,
  lib,
  host,
  ...
}:
let
  inherit (delib)
    module
    boolOption
    intOption
    moduleOptions
    strOption
    ;
  inherit (lib) flatten optional;
  serviceName = "grafana";
in
module {
  name = "services.grafana";

  options = moduleOptions {
    enable = boolOption false;
    port = intOption 8080;
    dataDir = strOption "/nas/database/${serviceName}";
    domain = strOption "";
    domainUrl = strOption "";
  };

  myconfig.ifEnabled =
    { myconfig, cfg, ... }:
    {
      services.${serviceName} = {
        domain = "${serviceName}.${myconfig.homelab.rootDomain}";
        domainUrl = "https://${serviceName}.${myconfig.homelab.rootDomain}";
      };
      homelab = {
        db.${serviceName} = {
          type = "postgres";
        };
        reverse-proxy.${serviceName} = {
          port = cfg.port;
          root = true;
          requireAuth = false;
        };
        users.db = [ serviceName ];
        users.monitoring = [ serviceName ];
        users.auth = [ serviceName ];
      };

    };

  nixos.ifEnabled =
    { myconfig, cfg, ... }:
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
          secrets.grafana_pocket_id_client_id = sopsConfig;
          secrets.grafana_pocket_id_client_secret = sopsConfig;
        };

      systemd.services.grafana = {
        after = [ "sops-nix.service" ];
        wants = [ "sops-nix.service" ];
      };

      systemd.tmpfiles.rules = [
        "d ${cfg.dataDir} 0770 ${serviceName} ${serviceName} - -"
      ];

      services.grafana = {
        enable = true;
        dataDir = cfg.dataDir;
        settings = {
          database = {
            type = "postgres";
            host = "127.0.0.1:5432";
            name = serviceName;
            user = serviceName;
          };
          server = {
            http_addr = "127.0.0.1";
            http_port = 8080;
            domain = cfg.domain;
            root_url = cfg.domainUrl;
          };
          auth = {
            disable_login_form = true;
            oauth_allow_insecure_email_lookup = true;
          };

          "auth.basic".enabled = false;
          "auth.passwordless".enabled = false;
          "auth.anonymous".enabled = false;
          "auth.ldap".enabled = false;
          "auth.saml".enabled = false;
          "auth.azuread".enabled = false;
          "auth.github".enabled = false;
          "auth.gitlab".enabled = false;
          "auth.grafana_com".enabled = false;
          "auth.okta".enabled = false;
          "auth.proxy".enabled = false;
          "auth.jwt".enabled = false;

          "auth.generic_oauth" = {
            enabled = true;
            allow_sign_up = false;
            name = "Passkey";
            client_id = "$__file{${config.sops.secrets.grafana_pocket_id_client_id.path}}";
            client_secret = "$__file{${config.sops.secrets.grafana_pocket_id_client_secret.path}}";
            scopes = "openid email profile groups";
            auth_url = "${myconfig.services.pocket-id.domain}/authorize";
            token_url = "${myconfig.services.pocket-id.domain}/api/oidc/token";
            api_url = "${myconfig.services.pocket-id.domain}/api/oidc/userinfo";
            email_attribute_path = "email";
            login_attribute_path = "email";
            use_refresh_token = true;
            login_prompt = "none";
            role_attribute_path = "contains(groups[*], 'admin') && 'Admin' || 'Viewer'";
            role_attribute_strict = false;
          };

          "auth.google" = {
            enabled = true;
            allow_sign_up = false;
            client_id = "$__file{${config.sops.secrets.oidc_google_client_id.path}}";
            client_secret = "$__file{${config.sops.secrets.oidc_google_secret.path}}";
            scopes = "openid email profile";
            auth_url = "https://accounts.google.com/o/oauth2/v2/auth";
            token_url = "https://oauth2.googleapis.com/token";
            api_url = "https://openidconnect.googleapis.com/v1/userinfo";
            allowed_domains = "${myconfig.homelab.rootDomain}";
            hosted_domain = "${myconfig.homelab.rootDomain}";
            email_attribute_path = "email";
            login_attribute_path = "email";
            use_refresh_token = true;
            login_prompt = "select_account";
          };
        };
        provision = {
          enable = true;
          datasources.settings.datasources = flatten [
            (optional myconfig.services.prometheus.enable {
              name = "Prometheus";
              type = "prometheus";
              url = "https://prometheus.${myconfig.homelab.rootDomain}";
              isDefault = true;
              editable = false;
            })
            (optional myconfig.services.influxdb.enable {
              name = "influxdb-pfsense";
              type = "influxdb";
              url = "https://influxdb.${myconfig.homelab.rootDomain}";
              editable = false;
              jsonData = {
                httpMode = "GET";
                dbName = "pfSense";
                httpHeaderName1 = "Authorization";
              };
              secureJsonData = {
                httpHeaderValue1 = "Token $__file{${config.sops.secrets.influxdb_grafana_read_token.path}}";
              };
            })
          ];
        };
      };
    };

}
