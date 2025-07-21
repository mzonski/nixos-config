{ delib, pkgs, ... }:
let
  inherit (delib) singleEnableOption module;
  inherit (builtins) concatStringsSep;
in
module {
  name = "programs.chrome";

  options = singleEnableOption false;

  home.ifEnabled =
    { myconfig, ... }:
    let
      commonFeatures = [
        "MiddleClickAutoscroll"
        "WaylandWindowDecorations"
      ];
      glesFeatures = [
        "AcceleratedVideoDecodeLinuxGL"
        "VaapiIgnoreDriverChecks"
        "VaapiOnNvidiaGPUs"
      ];
      vulkanFeatures = [
        "VulkanFromANGLE"
        "UseVulkanForWebGL"
      ];

      chromiumArgs = [
        "--ozone-platform-hint=auto"
        "--enable-features=${concatStringsSep "," (commonFeatures ++ glesFeatures)}"
      ];
    in
    {
      home.packages = with pkgs; [
        (google-chrome.override {
          commandLineArgs = chromiumArgs;
        })
        # (chromium.override {
        #   enableWideVine = true;
        #   commandLineArgs = chromiumArgs;
        # })
        (brave.override {
          commandLineArgs = chromiumArgs;
        })
      ];
    };
}
