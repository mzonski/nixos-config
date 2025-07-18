{
  config,
  pkgs,
  delib,
  lib,
  ...
}:

let
  inherit (delib) module;
  inherit (lib) concatStringsSep;
  qemuGroupName = "qemu-libvirtd";
  kvmfrDevice = "/dev/kvmfr0";
in
module {
  name = "features.virt-manager.vfio-passtrough";

  nixos.ifEnabled =
    { cfg, myconfig, ... }:
    let
      inherit (myconfig.admin) username;
      dgpuDevices = with cfg.devices; [
        dgpu-video
        dgpu-audio
      ];
    in
    {
      boot.kernelModules = [
        "vfio_pci"
        "vfio_iommu_type1"
        "vfio"

        "kvmfr"
      ];

      boot.extraModprobeConfig = ''
        options vfio-pci ids=${lib.concatStringsSep "," dgpuDevices}
        options kvmfr static_size_mb=${toString cfg.sharedMemorySize}
      '';

      boot.extraModulePackages = [ config.boot.kernelPackages.kvmfr ];
      services.udev.extraRules = ''
        SUBSYSTEM=="kvmfr", OWNER="${username}", GROUP="${qemuGroupName}", MODE="0660"
      '';

      environment.systemPackages = with pkgs; [
        looking-glass-client
      ];

      virtualisation.libvirtd.qemu.verbatimConfig = ''
        cgroup_device_acl = [
          "/dev/null",
          "/dev/full",
          "/dev/zero",
          "/dev/random",
          "/dev/urandom",
          "/dev/ptmx",
          "/dev/kvm",
          "/dev/rtc",
          "/dev/hpet",
          "${kvmfrDevice}",
        ]
      '';
    };
}
