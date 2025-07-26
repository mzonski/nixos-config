{
  delib,
  lib,
  host,
  pkgs,
  ...
}:
delib.module {
  name = "boot";

  # TODO: HOST IS NOT MINIMAL
  options = delib.singleEnableOption host.isDesktop;

  nixos.ifEnabled =
    let
      inherit (lib) mkDefault;
    in
    {
      boot.loader = {
        efi.canTouchEfiVariables = mkDefault true;
        timeout = 2;

        systemd-boot = {
          enable = true;

          edk2-uefi-shell.enable = false;
          configurationLimit = 10;

          extraInstallCommands = ''
            ${pkgs.coreutils}/bin/rm -f /boot/EFI/BOOT/BOOTX64.EFI
            [ -d /boot/EFI/BOOT ] && ${pkgs.coreutils}/bin/rmdir /boot/EFI/BOOT || true
          '';
        };
      };
    };
}
