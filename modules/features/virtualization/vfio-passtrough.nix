{
  config,
  pkgs,
  delib,
  lib,
  ...
}:

let
  inherit (delib) module;
  qemuGroupName = "qemu-libvirtd";
  kvmfrDevice = "/dev/kvmfr0";
in
module {
  name = "features.virt-manager.vfio-passtrough";

  myconfig.ifEnabled = {
    features.virt-manager.allowedDevices = [ kvmfrDevice ];
  };

  nixos.ifEnabled =
    { cfg, myconfig, ... }:
    let
      dgpuDevices = with cfg.devices; [
        dgpu-video
        dgpu-audio
      ];
      inherit (cfg) autoBindDevices;
    in
    {
      boot.kernelModules = [
        "vfio_pci"
        "vfio_iommu_type1"
        "vfio"

        "kvmfr"
      ];

      boot.extraModprobeConfig = ''
        ${lib.optionalString autoBindDevices "options vfio-pci ids=${lib.concatStringsSep "," dgpuDevices}"}

        options kvmfr static_size_mb=${toString cfg.sharedMemorySize}
      '';

      boot.extraModulePackages = [ config.boot.kernelPackages.kvmfr ];
      services.udev.extraRules = ''
        SUBSYSTEM=="kvmfr", GROUP="${qemuGroupName}", MODE="0660"
      '';

      environment.systemPackages = with pkgs; [
        looking-glass-client
      ];
    };
}
