{ delib, pkgs, ... }:
let
  inherit (delib)
    module
    moduleOptions
    boolOption
    strOption
    intOption
    ;
  serviceName = "public-files";
in
module {
  name = "services.public-files";

  options = moduleOptions {
    enable = boolOption false;
    dir = strOption "/nas/files/Public";
    uiPort = intOption 8091;
  };

  myconfig.ifEnabled =
    { cfg, ... }:
    {
      homelab.reverse-proxy.${serviceName} = {
        port = cfg.uiPort;
        subdomain = "public";
        requireAuth = false;
        root = true;
        public = true;
      };
    };

  nixos.ifEnabled =
    { cfg, ... }:
    {
      systemd.tmpfiles.rules = [
        "a+ ${builtins.dirOf cfg.dir} - - - - u:nginx:--x"
        "A+ ${cfg.dir} - - - - u:nginx:r-X,d:u:nginx:r-X"
      ];

      services.nginx.virtualHosts.${serviceName} = {
        listen = [
          {
            addr = "127.0.0.1";
            port = cfg.uiPort;
          }
        ];
        root = cfg.dir;
        locations."/".extraConfig = ''
          autoindex on;
          autoindex_exact_size off;
          autoindex_localtime on;
          disable_symlinks on;
        '';
      };

      systemd.services.nginx.unitConfig.RequiresMountsFor = cfg.dir;
    };
}
