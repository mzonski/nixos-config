{
  delib,
  pkgs,
  ...
}:

let
  inherit (delib)
    module
    boolOption
    strOption
    listOfOption
    submodule
    moduleOptions
    ;
  inherit (builtins) concatStringsSep;
in
module {
  name = "services.network-share-client";

  options = moduleOptions {
    enable = boolOption false;
    mounts = listOfOption (submodule {
      options = {
        resource = strOption "";
        target = strOption "";
      };
    }) [ ];
  };

  nixos.ifEnabled =
    { cfg, ... }:
    let
      escapeSystemdPath = path: pkgs.lib.replaceStrings [ "/" ] [ "-" ] (pkgs.lib.removePrefix "/" path);
    in
    {
      boot.supportedFilesystems = [ "nfs" ];
      services.rpcbind.enable = true;

      environment.systemPackages = with pkgs; [ nfs-utils ];

      systemd.mounts = map (mount: {
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
            "noauto"
          ];
          TimeoutSec = "15s";
          TimeoutStopSec = "10s";
        };
        what = mount.resource;
        where = mount.target;
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
      }) cfg.mounts;

      systemd.automounts = map (mount: {
        wantedBy = [ "multi-user.target" ];
        automountConfig = {
          TimeoutIdleSec = "15min";
          DeviceTimeoutSec = "15s";
        };
        where = mount.target;
      }) cfg.mounts;

      systemd.services.restart-nfs-after-suspend = {
        description = "Restart NFS mounts after suspend";
        after = [
          "suspend.target"
          "restart-network-after-suspend.service"
        ];
        wants = [ "restart-network-after-suspend.service" ];
        script = ''
          sleep 3
          ${concatStringsSep "\n" (
            map (
              mount: "${pkgs.systemd}/bin/systemctl restart ${escapeSystemdPath mount.target}.automount"
            ) cfg.mounts
          )}
        '';
        serviceConfig.Type = "oneshot";
      };
    };
}
