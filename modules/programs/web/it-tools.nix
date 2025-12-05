{ delib, pkgs, ... }:
let
  inherit (delib)
    module
    moduleOptions
    boolOption
    strOption
    assertEnabled
    ;
in
module {
  name = "programs.web.it-tools";

  options = moduleOptions (
    { myconfig, ... }:
    {
      enable = boolOption false;
      domain = strOption "${myconfig.homelab.rootDomain}";
    }
  );

  nixos.ifEnabled =
    { cfg, myconfig, ... }:
    {
      assertions = [
        (assertEnabled myconfig "services.nginx.enable")
      ];
      services.nginx = {
        virtualHosts."it-tools.${cfg.domain}" = {
          forceSSL = true;
          useACMEHost = cfg.domain;

          locations."/" = {
            root = "${pkgs.it-tools}/lib";
            tryFiles = "$uri $uri/ /index.html";
          };
        };
      };
    };
}
