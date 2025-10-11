{
  pkgs,
  lib,
  delib,
  ...
}:

let
  inherit (delib) module;

  inherit (import ../../../../lib/bash/devices.nix { inherit pkgs lib; })
    assertGpuDriver
    removeKernelModules
    loadKernelModules
    reattachDevices
    rebindDevice
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
        pkgs.coreutils
      ])}

      source ${displaySessionManipulation}
      source ${assertGpuDriver dgpuDevices}

      echo "=== Switching GPU to VFIO ==="
      ${beforeScript}

      assert_gpu_driver "vfio-pci"
      kill_display_session
      sleep 1

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
      sleep 1

      ${reattachDevices dgpuDevices}
      sleep 1

      ${rebindDevice "snd_hda_intel" "vfio-pci" devices.dgpu-audio}

      restore_display_session

      echo "=== VFIO drivers loaded ==="
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
