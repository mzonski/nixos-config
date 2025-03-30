{
  delib,
  lib,
  host,
  ...
}:
delib.module {
  name = "boot";

  options = delib.singleEnableOption host.not.isMinimal;

  nixos.ifEnabled =
    let
      inherit (lib) mkDefault;
    in
    {
      boot.loader = {
        efi.canTouchEfiVariables = mkDefault true;
        systemd-boot.enable = true;
        timeout = 3;
      };
    };
}
