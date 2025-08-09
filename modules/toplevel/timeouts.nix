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
      systemd.extraConfig = lib.mkIf (host.isDesktop or host.isMinimal) ''
        DefaultTimeoutStopSec=15s
        DefaultTimeoutStartSec=15s
      '';
    };
}
