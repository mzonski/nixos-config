{
  delib,
  host,
  lib,
  ...
}:
delib.module {
  name = "timeouts";

  nixos.always =
    { myconfig, ... }:
    {
      systemd.settings = lib.mkIf (host.isDesktop or host.isMinimal) {
        Manager = {
          DefaultTimeoutStopSec = "15s";
          DefaultTimeoutStartSec = "15s";
        };
      };
    };
}
