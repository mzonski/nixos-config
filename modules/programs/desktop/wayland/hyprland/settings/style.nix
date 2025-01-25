# {
#   config,
#   lib,
#   ...
# }:

# let
#   enabled = config.hom.wayland-wm.hyprland.enable;

#   inherit (lib) mkIf;
# in
# {
#   config = mkIf enabled {
#     wayland.windowManager.hyprland.settings = {
#       general = {
#         gaps_in = 4;
#         gaps_out = 8;
#         border_size = 2;
#         "col.active_border" = "rgb(cba6f7) rgb(94e2d5) 45deg";
#         "col.inactive_border" = "0x00000000";
#         border_part_of_window = false;
#         no_border_on_floating = false;
#         resize_on_border = true;
#       };

#       decoration = {
#         rounding = 0;
#         # active_opacity = 0.90;
#         # inactive_opacity = 0.90;
#         # fullscreen_opacity = 1.0;

#         blur = {
#           enabled = true;
#           size = 1;
#           passes = 1;
#           brightness = 1;
#           contrast = 1.4;
#           ignore_opacity = true;
#           noise = 0;
#           new_optimizations = true;
#           xray = true;
#         };

#         #drop_shadow = true;

#         #shadow_ignore_window = true;
#         #shadow_offset = "0 2";
#         #shadow_range = 20;
#         #shadow_render_power = 3;
#         #"col.shadow" = "rgba(00000055)";
#       };

#       animations = {
#         enabled = true;

#         bezier = [
#           "fluent_decel, 0, 0.2, 0.4, 1"
#           "easeOutCirc, 0, 0.55, 0.45, 1"
#           "easeOutCubic, 0.33, 1, 0.68, 1"
#           "easeinoutsine, 0.37, 0, 0.63, 1"
#         ];

#         animation = [
#           # Windows
#           "windowsIn, 1, 3, easeOutCubic, popin 30%" # window open
#           "windowsOut, 1, 3, fluent_decel, popin 70%" # window close.
#           "windowsMove, 1, 2, easeinoutsine, slide" # everything in between, moving, dragging, resizing.

#           # Fade
#           "fadeIn, 1, 3, easeOutCubic" # fade in (open) -> layers and windows
#           "fadeOut, 1, 2, easeOutCubic" # fade out (close) -> layers and windows
#           "fadeSwitch, 0, 1, easeOutCirc" # fade on changing activewindow and its opacity
#           "fadeShadow, 1, 10, easeOutCirc" # fade on changing activewindow for shadows
#           "fadeDim, 1, 4, fluent_decel" # the easing of the dimming of inactive windows
#           "border, 1, 2.7, easeOutCirc" # for animating the border's color switch speed
#           "borderangle, 1, 30, fluent_decel, once" # for animating the border's gradient angle - styles: once (default), loop
#           "workspaces, 1, 4, easeOutCubic, fade" # styles: slide, slidevert, fade, slidefade, slidefadevert
#         ];
#       };
#     };
#   };
# }
{ }
