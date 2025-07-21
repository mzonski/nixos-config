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
    pkgs.writeShellScriptBin "gpu-to-nvidia" ''
      [[ $EUID -ne 0 ]] && echo "Error: Root is required" && exit 1
      echo "=== Switching GPU to NVIDIA ==="
      VIRSH_BIN=${pkgs.libvirt}/bin/virsh
      RMMOD_BIN=${pkgs.kmod}/bin/rmmod
      MODPROBE_BIN=${pkgs.kmod}/bin/modprobe

      source ${getPciIdFromDeviceId}
      source ${checkGpuDriver dgpuDevices}

      check_gpu_driver "nvidia"

      ${concatMapStrings (deviceId: ''
        "$VIRSH_BIN" nodedev-reattach $(get_pci_id_from_device_id "${deviceId}")
        echo "Device ${deviceId} reattached to host"
      '') dgpuDevices}

      "$RMMOD_BIN" vfio_pci vfio_pci_core vfio_iommu_type1 vfio 
      echo "VFIO drivers removed"

      "$MODPROBE_BIN" -i nvidia nvidia_modeset nvidia_uvm nvidia_drm 
      echo "NVIDIA drivers loaded"
    '';

in
module {
  name = "features.virt-manager.vfio-passtrough";
  myconfig.ifEnabled =
    { cfg, ... }:
    {
      features.virt-manager.vfio-passtrough.scripts.gpu-to-nvidia = makeScript cfg.devices;
    };
}
