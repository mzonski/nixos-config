{
  delib,
  pkgs,
  ...
}:

let
  inherit (delib) module boolOption strOption;
  inherit (builtins) concatStringsSep;
in
module {
  name = "features.home-nas";

  options.features.home-nas = {
    enable = boolOption false;
    resource = strOption "10.0.1.4:/mnt/HOME/Files";
    target = strOption "/mnt/nas";
  };

  nixos.ifEnabled =
    { cfg, ... }:
    {
      boot.supportedFilesystems = [ "nfs" ];
      services.rpcbind.enable = true;

      environment.systemPackages = with pkgs; [ nfs-utils ];

      systemd.mounts = [
        {
          type = "nfs";
          mountConfig = {
            Options = concatStringsSep "," [
              "soft"
              "bg"
              "intr"
              "timeo=5"
              "nconnect=8"
              "vers=4"
              "_netdev"
              "comment=x-gvfs-show"
              "noauto"
            ];
            TimeoutSec = "15s";
            TimeoutStopSec = "10s";
          };
          what = cfg.resource;
          where = cfg.target;
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
        }
      ];

      systemd.automounts = [
        {
          wantedBy = [ "multi-user.target" ];
          automountConfig = {
            TimeoutIdleSec = "15min";
            DeviceTimeoutSec = "15s";
          };
          where = cfg.target;
        }
      ];

      systemd.services.restart-nfs-after-suspend = {
        description = "Restart NFS mounts after suspend";
        #wantedBy = [ "suspend.target" ];
        after = [
          "suspend.target"
          "restart-network-after-suspend.service"
        ];
        wants = [ "restart-network-after-suspend.service" ];
        script = ''
          sleep 3
          ${pkgs.systemd}/bin/systemctl restart mnt-nas.automount
        '';
        serviceConfig.Type = "oneshot";
      };
    };
}
