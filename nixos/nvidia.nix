{
  config,
  _lib,
  _pkgs,
  _modulesPath,
  ...
}:

{
  boot.kernelParams = [ "nvidia_drm.fbdev=1" ];
  # Graphics Configuration (Nvidia)
  hardware.opengl.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    # offload = {
    #   enable = true;
    #   enableOffloadCmd = true;
    # };
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    prime = {
      reverseSync.enable = true;
      allowExternalGpu = true;
      #sync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
