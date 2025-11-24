{
  delib,
  lib,
  host,
  pkgs,
  ...
}:

let
  inherit (delib)
    module
    moduleOptions
    boolOption
    strOption
    allowNull
    ;
  inherit (lib) optionalString;
in
module {
  name = "boot";

  options = moduleOptions {
    enable = boolOption (!host.isMinimal);
    windowsDiskId = allowNull (strOption null);
  };

  nixos.ifEnabled =
    { cfg, ... }:
    let
      inherit (lib) mkDefault;
    in
    {
      boot.loader = {
        efi.canTouchEfiVariables = mkDefault true;
        timeout = 3;

        grub = {
          enable = true;
          device = "nodev";
          efiSupport = true;
          font = "${pkgs.local.apple-fonts}/share/fonts/opentype/SF-Mono-Semibold.otf";
          fontSize = mkDefault 32;
          backgroundColor = "#000000";
          splashImage = null;
          extraEntries =
            optionalString (cfg.windowsDiskId != null) ''
              menuentry "Windows 11" {
                insmod part_gpt
                insmod fat
                search --no-floppy --fs-uuid --set=root ${cfg.windowsDiskId}
                chainloader /efi/Microsoft/Boot/bootmgfw.efi
              }
            ''
            + ''
              menuentry "UEFI Firmware" {
                fwsetup
              }
            '';
        };
      };
    };
}
