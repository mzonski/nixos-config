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
      services.${serviceName} = {
        enable = true;
        webExternalUrl = cfg.domainUrl;
        # stateDir = cfg.dataDir;
        listenAddress = "127.0.0.1";
        port = cfg.uiPort;
        globalConfig.scrape_interval = "10s";

        scrapeConfigs = [
          {
            job_name = "node";
            static_configs = [
              {
                targets = [ "localhost:9100" ];
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
