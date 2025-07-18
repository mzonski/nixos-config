{
  pkgs,
  lib,
  delib,
  ...
}:

let
  inherit (lib.strings) concatMapStrings;
  inherit (delib) module;

  inherit (import ../../../../lib/bash/devices.nix { inherit pkgs lib; })
    getPciIdFromDeviceId
    checkGpuDriver
    ;

  makeScript =
    devices:
    let
      dgpuDevices = [
        devices.dgpu-video
        devices.dgpu-audio
      ];
    in
    pkgs.writeShellScriptBin "gpu-to-vfio" ''
      echo "=== Switching GPU to VFIO ==="

      VIRSH_BIN=${pkgs.libvirt}/bin/virsh
      RMMOD_BIN=${pkgs.kmod}/bin/rmmod
      MODPROBE_BIN=${pkgs.kmod}/bin/modprobe
      SYSTEMCTL_BIN=${pkgs.systemd}/bin/systemctl
      TEE_BIN=${pkgs.coreutils}/bin/tee

      source ${getPciIdFromDeviceId}
      source ${checkGpuDriver dgpuDevices}

      check_gpu_driver "vfio-pci"

      "$SYSTEMCTL_BIN" stop display-manager.service

      echo 0 | "$TEE_BIN" /sys/class/vtconsole/vtcon0/bind > /dev/null
      echo 0 | "$TEE_BIN" /sys/class/vtconsole/vtcon1/bind > /dev/null
      sleep 1

      "$RMMOD_BIN" nvidia_uvm nvidia_drm nvidia_modeset nvidia
      echo "NVIDIA drivers removed"

      "$MODPROBE_BIN" -i vfio_pci vfio_pci_core vfio_iommu_type1 vfio
      echo "VFIO drivers loaded"

      ${concatMapStrings (deviceId: ''
        "$VIRSH_BIN" nodedev-reattach $(get_pci_id_from_device_id "${deviceId}")
        echo "Device ${deviceId} detached for VFIO"
      '') dgpuDevices}
      sleep 1

      echo 1 | "$TEE_BIN" /sys/class/vtconsole/vtcon0/bind > /dev/null
      echo 1 | "$TEE_BIN" /sys/class/vtconsole/vtcon1/bind > /dev/null
      sleep 1

      "$SYSTEMCTL_BIN" start display-manager.service
    '';

in
module {
  name = "features.virt-manager.vfio-passtrough";
  myconfig.ifEnabled =
    { cfg, ... }:
    {
      features.virt-manager.vfio-passtrough.scripts.gpu-to-vfio = makeScript cfg.devices;
    };
}
