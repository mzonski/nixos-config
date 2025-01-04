{
  options,
  config,
  lib,
  mylib,
  ...
}:

with lib;
with mylib;
let
  cfg = config.sys.hardware.graphics.xrandr;
in
{
  options.sys.hardware.graphics.xrandr = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {

    # TODO: Export output monitors to config, file not used anyway
    services.xserver = {
      exportConfiguration = true;
      enableCtrlAltBackspace = true;
      xrandrHeads = [
        {
          # LG 27UL850
          output = "DP-3";
          primary = true;

          monitorConfig = ''
            DisplaySize 600 340
            Modeline "3840x2160_60" 712.75 3840 4160 4576 5312 2160 2163 2168 2237 -HSync +VSync
            Option "PreferredMode" "3840x2160_60"
          '';
        }
        {
          # LG DualUp
          output = "HDMI-A-1";

          monitorConfig = ''
            DisplaySize 470 520
            Modeline "2560x2880_60" 638 2560 2784 3064 3568 2880 2883 2893 2982 -HSync +VSync
            Option "PreferredMode" "2560x2880_60"
          '';
        }
      ];
    };
  };
}
