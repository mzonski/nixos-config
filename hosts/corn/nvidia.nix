{
  delib,
  config,
  inputs,
  pkgs,
  lib,
  ...
}:

delib.host {
  name = "corn";

  myconfig.user.groups = [ "video" ];

  nixos = {
    imports = [
      inputs.nixos-hardware.nixosModules.common-gpu-nvidia
    ];

    boot.kernelParams = [
      "video=HDMI-A-2:d"
      "video=HDMI-A-3:d"
    ];

    boot.blacklistedKernelModules = [ "nouveau" ];

    environment.systemPackages = with pkgs; [
      vdpauinfo
      nvtopPackages.nvidia
      nvitop
    ];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        libvdpau-va-gl
        libGL
        egl-wayland
      ];
    };

    hardware.nvidia = {
      open = true;
      videoAcceleration = true;
      gsp.enable = true;
      modesetting.enable = true;

      powerManagement = {
        enable = true;
        finegrained = true;
        kernelSuspendNotifier = true;
      };

      prime = {
        offload.enable = true;
        sync.enable = false;
        reverseSync.enable = false;
        allowExternalGpu = false;

        amdgpuBusId = "PCI:71:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };

      #package = config.boot.kernelPackages.nvidiaPackages.latest;
      package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
        version = "610.57.04";
        sha256_64bit = "sha256-suk1xmuDuwDAyFe8jg7g/VLekoa0DJzB7sKafOfrEW0=";
        sha256_aarch64 = "sha256-QCefrMBCmpOwuOyXv1k5Gj0iB2CYlPgnG3JToUw/j54=";
        openSha256 = "sha256-rQHOOOY4KL92Ww3KDwh+j4eGU7oNAH8LutZC5wmFnPo=";
        settingsSha256 = "sha256-ZEMo8I8Zc2Tq6RVDNYpAH+f094dUaZiBqO+5f6lIjRI=";
        persistencedSha256 = "sha256-aXmD2VY1RLlgAnlHhOUMWzvMyhI6JTClcFLm4imF/mA=";
      };
    };
  };
}
