{
  host,
  delib,
  pkgs,
  ...
}:
let
  inherit (delib) module boolOption;
  inherit (builtins) concatStringsSep;
in
module {
  name = "programs.chrome";

  options.programs.chrome = {
    enable = boolOption host.isDesktop;
    useVulkan = boolOption false;
  };

  home.ifEnabled =
    { cfg, myconfig, ... }:
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

      selectedFeatures = if cfg.useVulkan then vulkanFeatures else glesFeatures;

      chromiumArgs = [
        "--ozone-platform-hint=auto"
        "--enable-features=${concatStringsSep "," (commonFeatures ++ selectedFeatures)}"
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
