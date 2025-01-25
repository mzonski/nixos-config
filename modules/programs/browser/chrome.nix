# {
#   config,
#   lib,
#   pkgs,
#   lib',
#   ...
# }:

# let
#   enabled = config.programs.chrome.enable;
#   # Still no HW accel on wayland. X11 works like a charm. hopefully it will be fixed in 570
#   # GDK_SCALE=2 google-chrome-stable --ozone-platform=x11 --ozone-platform-hint=auto --use-angle=vulkan --enable-features=Vulkan,VulkanFromANGLE,DefaultANGLEVulkan
#   # https://issues.chromium.org/issues/40225939
#   chromiumArgs = [
#     "--ozone-platform-hint=auto"
#     "--enable-features=MiddleClickAutoscroll,AcceleratedVideoDecodeLinuxZeroCopyGL,AcceleratedVideoDecodeLinuxGL,VaapiIgnoreDriverChecks,VaapiOnNvidiaGPUs"
#   ];

#   inherit (lib') mkBoolOpt;
#   inherit (lib) mkIf;
# in
# {
#   options.programs.chrome = {
#     enable = mkBoolOpt false;
#   };

#   config = mkIf enabled {
#     home.packages = with pkgs; [
#       (google-chrome.override {
#         commandLineArgs = chromiumArgs;
#       })
#       (chromium.override {
#         enableWideVine = true;
#         #commandLineArgs = chromiumArgs;
#       })
#     ];
#   };
# }
{ }
