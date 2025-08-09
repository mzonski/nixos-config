{
  pkgs,
  lib,
  delib,
  ...
}:

let
  inherit (delib) module;

  inherit (import ../../../../lib/bash/devices.nix { inherit pkgs lib; })
    checkGpuDriver
    removeKernelModules
    loadKernelModules
    reattachDevices
    ;
  inherit (import ../../../../lib/bash/utils.nix { inherit lib; })
    extendPath
    requireRoot
    ;

  displaySessionManipulation = pkgs.writeShellScript "display_session_manipulation" ''
    ${extendPath [
      pkgs.systemd
      pkgs.coreutils
    ]}

    kill_display_session() {
      systemctl stop display-manager.service
      sleep 1

      echo 0 | tee /sys/class/vtconsole/vtcon0/bind > /dev/null
      echo 0 | tee /sys/class/vtconsole/vtcon1/bind > /dev/null
      sleep 1
    }

    restore_display_session() {
      echo 1 | tee /sys/class/vtconsole/vtcon0/bind > /dev/null
      echo 1 | tee /sys/class/vtconsole/vtcon1/bind > /dev/null
      sleep 1

      systemctl start display-manager.service
      sleep 1
    }
  '';

  makeScript =
    devices:
    let
      dgpuDevices = [
        devices.dgpu-video
        devices.dgpu-audio
      ];
    in
    pkgs.writeShellScriptBin "gpu-to-vfio" ''
      ${requireRoot}

      ${extendPath ([
        pkgs.libvirt
        pkgs.kmod
      ])}

      source ${displaySessionManipulation}
      source ${checkGpuDriver dgpuDevices}

      echo "=== Switching GPU to VFIO ==="

      check_gpu_driver "vfio-pci"
      kill_display_session

      ${removeKernelModules [
        "nvidia_uvm"
        "nvidia_drm"
        "nvidia_modeset"
        "nvidia"
      ]}
      echo "NVIDIA drivers removed"

      ${loadKernelModules [
        "vfio_pci"
        "vfio_pci_core"
        "vfio_iommu_type1"
        "vfio"
      ]}
      echo "VFIO drivers loaded"

      ${reattachDevices dgpuDevices}

      restore_display_session

      echo "VFIO drivers removed"
      sleep 1
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
