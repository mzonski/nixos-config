{ delib, pkgs, ... }:
let
  inherit (delib) singleEnableOption module;
in
module {
  name = "programs.chrome";

  options = singleEnableOption false;

  home.ifEnabled =
    { myconfig, ... }:
    let
      chromiumArgs = [
        "--ozone-platform-hint=auto"
        "--enable-features=MiddleClickAutoscroll,AcceleratedVideoDecodeLinuxZeroCopyGL,AcceleratedVideoDecodeLinuxGL,VaapiIgnoreDriverChecks,VaapiOnNvidiaGPUs"
      ];
    in
    {
      home.packages = with pkgs; [
        (google-chrome.override {
          commandLineArgs = chromiumArgs;
        })
        (chromium.override {
          enableWideVine = true;
          commandLineArgs = chromiumArgs;
        })
      ];
    };
}
