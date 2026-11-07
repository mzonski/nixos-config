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
      inputs.nixZpkgs.nixosHardware.modules.common-gpu-nvidia
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
        version = "620.70.06";
        sha256_64bit = "sha256-KRGOOr0IwHVZvMo9nHYjjQOUkK8DYqLlvPy+cgSv1LE=";
        sha256_aarch64 = "sha256-P6ZaknHg3eKk5YxJZcOIhaAqOkKszcsm/IF0EGB/PgM=";
        openSha256 = "sha256-dV8vzniUl3UJoG2Q3KdoUJigLRuQeTniUfB670gb1Mw=";
        settingsSha256 = "sha256-CFBRmXFJ9eAf5BRlHMBolahz1Pshr9giI7zcZC29oZ8=";
        persistencedSha256 = "sha256-FpGzhArrvR1nEt8lKDzNEnbvHvGP36gL1dINvpDAkpA=";
      };
    };
  };
}
