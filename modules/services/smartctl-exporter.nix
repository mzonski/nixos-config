{ delib, pkgs, ... }:
let
  inherit (delib)
    module
    boolOption
    intOption
    strOption
    moduleOptions
    ;
  serviceName = "smartctl-exporter";
in
module {
  name = "services.${serviceName}";

  options = moduleOptions {
    enable = boolOption false;
    port = intOption 9633;
    listenAddress = strOption "0.0.0.0";
  };

  nixos.ifEnabled =
    { myconfig, cfg, ... }:
    {
      services.prometheus.exporters.smartctl = {
        inherit (cfg) port listenAddress;
        enable = true;
        openFirewall = true;
        maxInterval = "30m";
        devices = [
          "/dev/sda"
          "/dev/sdb"
          "/dev/nvme0"
        ];

        user = "root";
        group = serviceName;
      };

      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="nvme", KERNEL=="nvme[0-9]*", RUN+="${pkgs.acl}/bin/setfacl -m g:${serviceName}:rw /dev/$kernel"
        ACTION=="add", SUBSYSTEM=="block", KERNEL=="sd[a-z]*", RUN+="${pkgs.acl}/bin/setfacl -m g:${serviceName}:rw /dev/$kernel"
      '';
    };
}
