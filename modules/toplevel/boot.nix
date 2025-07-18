{
  delib,
  lib,
  host,
  pkgs,
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
        timeout = 3;

        systemd-boot = {
          enable = true;
          extraInstallCommands = ''
            ${pkgs.coreutils}/bin/rm -f /boot/EFI/BOOT/BOOTX64.EFI
            [ -d /boot/EFI/BOOT ] && ${pkgs.coreutils}/bin/rmdir /boot/EFI/BOOT || true
          '';
        };
      };
    };
}
