{ delib, host, ... }:
let
  inherit (delib)
    module
    boolOption
    intOption
    moduleOptions
    ;
in
module {
  name = "services.grafana";

  options = moduleOptions {
    enable = boolOption false;
    port = intOption 8080;
  };

  myconfig.ifEnabled =
    { cfg, ... }:
    {
      homelab.reverse-proxy.grafana.port = cfg.port;
    };

  nixos.ifEnabled =
    { myconfig, cfg, ... }:
    {
      services.grafana = {
        enable = true;
        provision = {
          enable = true;
        };
        settings = {
          server = {
            http_addr = "127.0.0.1";
            http_port = 8080;
            domain = "grafana.${host.name}.${myconfig.homelab.domain}";
          };
        };
      };
    };
}
