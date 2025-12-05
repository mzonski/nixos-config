{
  delib,
  lib,
  host,
  homeManagerUser,
  config,
  ...
}:
let
  inherit (delib)
    module
    boolOption
    intOption
    strOption
    moduleOptions
    ;
  inherit (lib) mkForce;
  inherit (builtins) toString;
  serviceName = "influxdb";
  username = "influxdb2";
in
module {
  name = "services.influxdb";

  options = moduleOptions {
    enable = boolOption false;
    uiPort = intOption 8089;
    serviceDir = strOption "/nas/database/${serviceName}";
  };

  myconfig.ifEnabled =
    { cfg, ... }:
    {
      homelab.reverse-proxy.${serviceName} = {
        port = cfg.uiPort;
        root = true;
        requireAuth = false;
      };
      user.groups = [ username ];
      homelab.users.db = [ username ];
      homelab.users.monitoring = [ username ];
    };

  nixos.ifEnabled =
    { myconfig, cfg, ... }:
    {
      users.users.${username}.uid = 987;
      users.groups.${username}.gid = 982;

      networking.firewall.allowedTCPPorts = [ cfg.uiPort ];

      sops =
        let
          sopsConfig = {
            sopsFile = host.secretsFile;
            owner = username;
            group = username;
          };
        in
        {
          secrets.influxdb_admin_password = sopsConfig;
          secrets.influxdb_admin_token = sopsConfig;
          secrets.influxdb_pfsense_write_token = sopsConfig;
        };

      systemd.tmpfiles.rules = [
        "d ${cfg.serviceDir} 0770 ${username} ${username} - -"
      ];

      fileSystems."/var/lib/influxdb2" = {
        device = cfg.serviceDir;
        options = [ "bind" ];
      };

      systemd.services.influxdb2 = {
        after = [ "zfs.target" ];
        requires = [ "zfs.target" ];
        serviceConfig = {
          User = username;
          Group = username;
        };
      };

      services.influxdb2 = {
        enable = true;
        settings = {
          http-bind-address = "127.0.0.1:${toString cfg.uiPort}";
          log-level = "info";
          reporting-disabled = true;

          storage-cache-max-memory-size = 1073741824; # 1GB
          storage-cache-snapshot-memory-size = 26214400; # 25MB
          storage-wal-fsync-delay = "0s";
        };

        provision = {
          enable = true;

          initialSetup = {
            organization = "Homelab";
            bucket = "homelab";
            username = "${homeManagerUser}";
            passwordFile = config.sops.secrets.influxdb_admin_password.path;
            tokenFile = config.sops.secrets.influxdb_admin_token.path;
            retention = 0; # infinite
          };

          organizations.Homelab = {
            present = true;
            description = "Homelab";

            buckets = {
              homelab = {
                present = true;
                description = "General metrics";
                retention = mkForce 2592000; # 30 days
              };

              pfSense = {
                present = true;
                description = "pfSense router";
                retention = mkForce 2592000;
              };

              system = {
                present = true;
                description = "System metrics";
                retention = mkForce 2592000;
              };
            };

            auths = {
              pfsense-writer = {
                present = true;
                tokenFile = config.sops.secrets.influxdb_pfsense_write_token.path;

                writeBuckets = [ "pfSense" ];
                readBuckets = [ ];
              };

              grafana-reader = {
                present = true;
                tokenFile = config.sops.secrets.influxdb_grafana_read_token.path;

                readBuckets = [
                  "pfSense"
                  "homelab"
                  "system"
                ];
                writeBuckets = [ ];
              };

              admin = {
                present = true;
                allAccess = true;
                tokenFile = config.sops.secrets.influxdb_admin_token.path;
              };
            };
          };
        };
      };
    };
}
