{ delib, ... }:
delib.module {
  name = "directories";

  options = delib.singleEnableOption true;

  nixos.ifEnabled = {
    systemd.tmpfiles.rules = [ "d /run/hardware 0755 root root -" ];
  };
}
