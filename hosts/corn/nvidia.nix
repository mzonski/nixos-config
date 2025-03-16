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

    boot.blacklistedKernelModules = [
      "i915"
      "amdgpu"
      "nouveau"
    ];
    services.xserver.videoDrivers = [ "nvidia" ];

    environment.systemPackages = with pkgs; [
      libva-utils
      vdpauinfo
    ];

    environment.variables = {
      MESA_VK_DEVICE_SELECT_FORCE_DEFAULT_DEVICE = "1";
      MESA_LOADER_DRIVER_OVERRIDE = "nvidia";

      LIBVA_DRIVER_NAME = "nvidia";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      NVD_BACKEND = "direct";
    };

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        nvidia-vaapi-driver # remove 25.05?
        vaapiVdpau
        libvdpau-va-gl
        libva1
        libGL

        egl-wayland
      ];
    };

    hardware.nvidia = {
      modesetting.enable = true;

      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = true;

      forceFullCompositionPipeline = true;
      gsp.enable = true;
      # videoAcceleration = true; # 25.05?

      prime = {
        offload.enable = false;
        sync.enable = false;
        reverseSync.enable = true;
        allowExternalGpu = false;

        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };

      #package = config.boot.kernelPackages.nvidiaPackages.latest;
      package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
        version = "570.124.04";
        sha256_64bit = "sha256-G3hqS3Ei18QhbFiuQAdoik93jBlsFI2RkWOBXuENU8Q=";
        sha256_aarch64 = "sha256-HN58N00SNEwMQKSKuOMAXVW6J2VI/2YyDulQNJHuVeM=";
        openSha256 = "sha256-KCGUyu/XtmgcBqJ8NLw/iXlaqB9/exg51KFx0Ta5ip0=";
        settingsSha256 = "sha256-LNL0J/sYHD8vagkV1w8tb52gMtzj/F0QmJTV1cMaso8=";
        persistencedSha256 = "sha256-SHSdnGyAiRH6e0gYMYKvlpRSH5KYlJSA1AJXPm7MDRk=";
      };
    };

    #hardware.nvidia-container-toolkit = {
    #  enable = false;
    #};
  };
}
