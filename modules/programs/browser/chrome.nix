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
      # Still no HW accel on wayland. X11 works like a charm. hopefully it will be fixed in 570
      # GDK_SCALE=2 google-chrome-stable --ozone-platform=x11 --ozone-platform-hint=auto --use-angle=vulkan --enable-features=Vulkan,VulkanFromANGLE,DefaultANGLEVulkan
      # https://issues.chromium.org/issues/40225939
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
          #commandLineArgs = chromiumArgs;
        })
      ];
    };
}
