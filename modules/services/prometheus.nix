{ delib, ... }:
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
            scrape_interval = "5m";
            scrape_timeout = "5m";
            static_configs = [
              {
                targets = [
                  "corn:9100"
                ];
              }
            ];
          }
        ];

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
