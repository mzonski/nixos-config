{ delib, lib, ... }:
delib.module {
  name = "boot";

  nixos.always =
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
