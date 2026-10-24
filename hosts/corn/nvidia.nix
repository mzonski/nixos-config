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
        version = "615.71.09";
        sha256_64bit = "sha256-zc7tIrvrYSSNGm3qvCWWZz46ZQFpjucayNL9wo87cP4=";
        sha256_aarch64 = "sha256-IbekQhE7cFfmnPZaLY9NDYcF7CoNZ+2Qb7sRd4EOgWM=";
        openSha256 = "sha256-3gByMYIwFzRaLdDG+roCEOuKRRJDrljG9AlLnRZTirM=";
        settingsSha256 = "sha256-LK1LU8mDkM/XVRKPBtuOZh9nIP/lGFLAJnmasEX8jhg=";
        persistencedSha256 = "sha256-qPRb+3d88+2RcpUkoBTbjIaImnQ+jX+/6p1vXcJ5geE=";
      };
    };
  };
}
