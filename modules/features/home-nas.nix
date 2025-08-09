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
              "timeo=150"
              "nconnect=8"
              "vers=4"
              "_netdev"
              "comment=x-gvfs-show"
            ];
            TimeoutSec = "15s";
            TimeoutStopSec = "10s";
          };
          what = cfg.resource;
          where = cfg.target;
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
    };
}
