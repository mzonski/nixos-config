{ config, ... }:

{
  services.xserver = {
    exportConfiguration = true;
    enableCtrlAltBackspace = true;
    xrandrHeads = [
      {
        # LG 27UL850
        output = "DP-4";
        primary = true;

        monitorConfig = ''
          DisplaySize 600 340
          Modeline "3840x2160_60" 712.75 3840 4160 4576 5312 2160 2163 2168 2237 -HSync +VSync
          Option "PreferredMode" "3840x2160_60"
        '';
      }
      {
        # LG DualUp
        output = "HDMI-0";

        monitorConfig = ''
          DisplaySize 470 520
          Modeline "2560x2880_60" 638 2560 2784 3064 3568 2880 2883 2893 2982 -HSync +VSync
          Option "PreferredMode" "2560x2880_60"
        '';
      }
    ];

    videoDrivers = [
      "nvidia"
    ];
  };

  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;

    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;

    forceFullCompositionPipeline = false;
    gsp.enable = true;

    prime = {
      offload.enable = false;
      sync.enable = false;

      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };
}
