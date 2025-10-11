{
  pkgs,
  lib,
  delib,
  ...
}:
let
  inherit (delib) module;
  inherit (lib) optional;

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

  makeScript =
    {
      devices,
      preScript,
      postScript,
    }:
    let
      dgpuDevices = [
        devices.dgpu-video
        devices.dgpu-audio
      ];
    in
    pkgs.writeShellScriptBin "gpu-to-nvidia" ''
      ${requireRoot}

      ${extendPath ([
        pkgs.libvirt
        pkgs.kmod
        pkgs.coreutils
      ])}

      echo "=== Switching GPU to NVIDIA ==="
      source ${assertGpuDriver dgpuDevices}

      assert_gpu_driver "nvidia"

      ${preScript}

      ${reattachDevices dgpuDevices}

      ${removeKernelModules [
        "vfio_pci"
        "vfio_pci_core"
        "vfio_iommu_type1"
        "vfio"
      ]}
      echo "VFIO drivers removed"
      sleep 1

      ${loadKernelModules [
        "nvidia"
        "nvidia_modeset"
        "nvidia_uvm"
        "nvidia_drm"
      ]}

      ${rebindDevice "vfio-pci" "snd_hda_intel" devices.dgpu-audio}

      ${postScript}

      echo "=== NVIDIA drivers loaded ==="
    '';
in
module {
  name = "features.virt-manager.vfio-passtrough";
  myconfig.ifEnabled =
    { cfg, myconfig, ... }:
    {
      features.virt-manager.vfio-passtrough.scripts.gpu-to-nvidia = makeScript ({
        devices = cfg.devices;
        preScript =
          if cfg.scripts.hooks.preGpuToNvidia != null then cfg.scripts.hooks.preGpuToNvidia else "";
        postScript =
          if cfg.scripts.hooks.postGpuToNvidia != null then cfg.scripts.hooks.postGpuToNvidia else "";
      });
    };
}
