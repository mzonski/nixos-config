{ config, ... }:

{
  boot.kernelParams = [ "nvidia_drm.fbdev=1" ];
  services.xserver = {
    exportConfiguration = true;
    xrandrHeads = [
      {
        # Configure the LG 27UL850-W (primary monitor)
        output = "HDMI-5";
        primary = true;

        # DisplaySize based on the dimensions reported by xrandr: 600mm x 340mm
        monitorConfig = ''
          DisplaySize 600 340
          Modeline "3840x2160_60" 712.75 3840 4160 4576 5312 2160 2163 2168 2237 -HSync +VSync
          Option "PreferredMode" "3840x2160_60"
        '';
      }
      {
        # Configure the LG DualUp monitor
        output = "DP-2";

        # DisplaySize based on xrandr: 470mm x 520mm
        monitorConfig = ''
          DisplaySize 470 520
          Modeline "2560x2880_60" 638 2560 2784 3064 3568 2880 2883 2893 2982 -HSync +VSync
          Option "PreferredMode" "2560x2880_60"
          Option "RightOf" "HDMI-1"
        '';
      }
    ];

    videoDrivers = [ "nvidia" ];
  };

  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
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
