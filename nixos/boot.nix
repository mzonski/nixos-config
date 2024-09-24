{
  _config,
  _lib,
  _pkgs,
  _modulesPath,
  ...
}:

{
  # Bootloader Configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices."luks-6b1c8646-f768-4c08-b5ba-77462f4b4d4e".device = "/dev/disk/by-uuid/6b1c8646-f768-4c08-b5ba-77462f4b4d4e";
}
