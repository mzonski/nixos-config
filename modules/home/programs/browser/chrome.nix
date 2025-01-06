{
  config,
  lib,
  pkgs,
  mylib,
  ...
}:

with lib;
with mylib;
let
  enabled = config.programs.chrome.enable;
  # Still no HW accel :/
  # https://issues.chromium.org/issues/40225939
  chromiumArgs = [
    "--ozone-platform-hint=auto"
    "--enable-features=MiddleClickAutoscroll,AcceleratedVideoDecodeLinuxZeroCopyGL,AcceleratedVideoDecodeLinuxGL,VaapiIgnoreDriverChecks,VaapiOnNvidiaGPUs"
  ];
in
{
  options.programs.chrome = {
    enable = mkBoolOpt false;
  };

  config = mkIf enabled {
    home.packages = with pkgs; [
      (google-chrome.override {
        commandLineArgs = chromiumArgs;
      })
      # (chromium.override {
      #   enableWideVine = true;
      #   commandLineArgs = chromiumArgs;
      # })
    ];
  };
}
