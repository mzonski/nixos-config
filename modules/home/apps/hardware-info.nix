{
  config,
  options,
  lib,
  pkgs,
  mylib,
  ...
}:

with lib;
with mylib;
let
  cfg = config.hom.apps;
in
{
  options.hom.apps = {
    hardware-info = mkBoolOpt false;
  };

  config = mkIf cfg.hardware-info {
    home.packages = with pkgs; [
      fwupd
      pciutils # peek/edit PCI devices config
      clinfo
      libglvnd
      glxinfo
      vulkan-tools
      lshw
    ];
  };
}
