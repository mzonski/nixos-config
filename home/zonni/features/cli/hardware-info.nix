{ pkgs, ... }:
{
  home.packages = (
    with pkgs;
    [
      fwupd
      pciutils # peek/edit PCI devices config
      clinfo
      libglvnd
      glxinfo
      vulkan-tools
      lshw
    ]
  );
}
