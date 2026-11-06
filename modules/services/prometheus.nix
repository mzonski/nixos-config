{
  delib,
  host,
  config,
  pkgs,
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
  serviceName = "prometheus";
in
module {
  name = "services.${serviceName}";

  options = moduleOptions {
    enable = boolOption false;
    uiPort = intOption 8087;
    domainUrl = strOption "";
    dataDir = strOption "/nas/databases/${serviceName}";
  };

  myconfig.ifEnabled =
    { myconfig, cfg, ... }:
    {
      services.${serviceName}.domainUrl = "https://${serviceName}.${myconfig.homelab.rootDomain}";

      homelab.reverse-proxy.${serviceName} = {
        port = cfg.uiPort;
        root = true;
        requireAuth = false;
      };
    };

  nixos.ifEnabled =
    { myconfig, cfg, ... }:
    {
      systemd.services.prometheus = {
        after = [ "zfs.target" ];
        requires = [ "zfs.target" ];
      };

      sops = {
        secrets = {
          tailscale_tailnet.sopsFile = host.secretsFile;
          tailscale_oauth_client_id.sopsFile = host.secretsFile;
          tailscale_oauth_client_secret.sopsFile = host.secretsFile;
        };
        templates.tailscale_exporter.content = ''
          TAILSCALE_TAILNET=${config.sops.placeholder.tailscale_tailnet}
          TAILSCALE_OAUTH_CLIENT_ID=${config.sops.placeholder.tailscale_oauth_client_id}
          TAILSCALE_OAUTH_CLIENT_SECRET=${config.sops.placeholder.tailscale_oauth_client_secret}
        '';
      };

      services.${serviceName} = {
        enable = true;
        webExternalUrl = cfg.domainUrl;
        # stateDir = cfg.dataDir;
        listenAddress = "127.0.0.1";
        port = cfg.uiPort;
        globalConfig.scrape_interval = "10s";

        # TODO: Refactor
        scrapeConfigs = [
          {
            job_name = "node";
            static_configs = [
              {
                targets = [
                  "tomato:9100"
                ];
              }
            ];
          }
          {
            job_name = "speedtest";
            scrape_interval = "5m";
            scrape_timeout = "5m";
            static_configs = [
              {
                targets = [
                  "tomato:9798"
                ];
              }
            ];
          }
          {
            job_name = "smart";
            scrape_interval = "1h";
            scrape_timeout = "1h";
            static_configs = [
              {
                targets = [
                  "tomato:${toString myconfig.services.smartctl-exporter.port}"
                ];
              }
            ];
          }
          {
            job_name = "corn_win";
            scrape_interval = "30s";
            scrape_timeout = "10s";
            static_configs = [
              {
                targets = [
                  "corn:9100"
                ];
              }
            ];
          }
          {
            job_name = "tailscale";
            scrape_interval = "1m";
            static_configs = [
              {
                targets = [
                  "tomato:${toString config.services.prometheus.exporters.tailscale.port}"
                ];
              }
            ];
          }
          {
            job_name = "tailscale-client";
            scrape_interval = "1m";
            static_configs = [
              {
                targets = [ "100.100.100.100:80" ];
                labels.tailscale_machine = host.name;
              }
            ];
          }
        ];

        exporters.tailscale = {
          enable = true;
          package = pkgs.unstable.prometheus-tailscale-exporter;
          environmentFile = config.sops.templates.tailscale_exporter.path;
        };

        exporters.node = {
          enable = true;
          port = 9100;
          enabledCollectors = [
            "systemd"
            "processes"
            "nfs"
            "nfsd"
          ];
        };
      };
    };
}
