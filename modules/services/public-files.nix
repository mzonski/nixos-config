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
    parentGroup = strOption "nas-files";
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
      users.users.nginx.extraGroups = [ cfg.parentGroup ];

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

      systemd.services.chmod-public-files = {
        description = "Keep public files readable by nginx";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = [
            "${pkgs.coreutils}/bin/chgrp -R ${cfg.parentGroup} ${cfg.dir}"
            "${pkgs.coreutils}/bin/chmod -R g+rX ${cfg.dir}"
          ];
        };
      };

      systemd.timers.chmod-public-files = {
        description = "Run chmod-public-files hourly";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "hourly";
          Persistent = true;
        };
      };

      systemd.services.nginx.unitConfig.RequiresMountsFor = cfg.dir;
    };
}
