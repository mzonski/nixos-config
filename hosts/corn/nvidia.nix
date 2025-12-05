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
      libva-utils
      vdpauinfo

      nvtopPackages.nvidia
    ];

    environment.variables = {
      #MESA_VK_DEVICE_SELECT_FORCE_DEFAULT_DEVICE = "1";
      #MESA_LOADER_DRIVER_OVERRIDE = "nvidia";

      #LIBVA_DRIVER_NAME = "nvidia";
      #GBM_BACKEND = "nvidia-drm";
      #__GLX_VENDOR_LIBRARY_NAME = "nvidia";
      #NVD_BACKEND = "direct";

      #__NV_PRIME_RENDER_OFFLOAD = 1;
      #_NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
      #__VK_LAYER_NV_optimus = "NVIDIA_only";
    };

    #environment.sessionVariables = {
    #  VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
    #};

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        nvidia-vaapi-driver # remove 25.05?
        libva-vdpau-driver
        libvdpau-va-gl
        libva1
        libGL

        egl-wayland
      ];
    };

    hardware.nvidia = {
      modesetting.enable = true;

      powerManagement.enable = true;
      powerManagement.finegrained = true;
      open = true;

      forceFullCompositionPipeline = false;
      gsp.enable = true;
      # videoAcceleration = true; # 25.05?

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
        version = "590.44.01";
        sha256_64bit = "sha256-VbkVaKwElaazojfxkHnz/nN/5olk13ezkw/EQjhKPms=";
        sha256_aarch64 = "sha256-gpqz07aFx+lBBOGPMCkbl5X8KBMPwDqsS+knPHpL/5g=";
        openSha256 = "sha256-ft8FEnBotC9Bl+o4vQA1rWFuRe7gviD/j1B8t0MRL/o=";
        settingsSha256 = "sha256-wVf1hku1l5OACiBeIePUMeZTWDQ4ueNvIk6BsW/RmF4=";
        persistencedSha256 = "sha256-nHzD32EN77PG75hH9W8ArjKNY/7KY6kPKSAhxAWcuS4=";
      };
    };
  };

  home = {
    dconf.settings."org/gnome/mutter".experimental-features = [ "kms-modifiers" ];
  };
}
