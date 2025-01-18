{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia
  ];

  boot.blacklistedKernelModules = [
    # "i915"
    "amdgpu"
  ];
  services.xserver.videoDrivers = [ "nvidia" ];

  environment.systemPackages = with pkgs; [
    libva-utils
    vdpauinfo

  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver # remove 25.05?
      vaapiVdpau
      libvdpau-va-gl
      libva1
    ];
  };

  hardware.nvidia = {
    modesetting.enable = true;

    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = true;

    forceFullCompositionPipeline = true;
    gsp.enable = true;
    #videoAcceleration = true; 25.05?

    prime = {
      offload.enable = false;
      sync.enable = false;

      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  hardware.nvidia-container-toolkit = {
    enable = false;
  };

  virtualisation.docker = {
    enableNvidia = true;
  };

  host.user.extraGroups = [ "video" ];
}
