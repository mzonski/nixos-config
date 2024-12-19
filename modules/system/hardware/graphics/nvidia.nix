{
  options,
  config,
  lib,
  pkgs,
  mylib,
  ...
}:

with lib;
with mylib;
let
  cfg = config.sys.hardware.graphics.nvidia;
in
{
  options.sys.hardware.graphics.nvidia = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.graphics.enable = true;
    hardware.graphics.enable32Bit = true;

    hardware.nvidia = {
      modesetting.enable = true;

      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = true;

      forceFullCompositionPipeline = true;
      gsp.enable = true;

      prime = {
        offload.enable = false;
        sync.enable = false;

        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };

    hardware.nvidia-container-toolkit = {
      enable = true;
    };

    virtualisation.docker = {
      enableNvidia = true;
    };

    sys.user.extraGroups = [ "video" ];
  };
}
