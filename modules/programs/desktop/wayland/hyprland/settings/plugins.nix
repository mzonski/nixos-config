{ delib, ... }:
let
  inherit (delib) module;
in
module {
  name = "programs.wayland";

  home.ifEnabled =
    { myconfig, ... }:
    {
      wayland.windowManager.hyprland.settings.plugin = {
        hyprbars = {
          bar_color = "rgb(1E1E2E)";
          col.text = "rgb(CDD6F4)";
          bar_text_font = myconfig.rice.fonts.regular.name;
          bar_text_align = "left";
          bar_buttons_alignment = "right";
          bar_height = 32;
          bar_text_size = 12;
          bar_padding = 4;
          bar_button_padding = 2;

          bar_title_enabled = true;
          bar_blur = false;
          bar_part_of_window = true;
          bar_precedence_over_border = false;

          hyprbars-button = [
            "rgb(000000), 24,  󰖭  , hyprctl dispatch killactive, rgb(f38ba8)"
            "rgb(000000), 24,    , hyprctl dispatch fullscreen 1"
            "rgb(000000), 24,  󰛺  , hyprctl dispatch pseudo"
            "rgb(000000), 24,    , hyprctl dispatch togglefloating"
          ];
        };

        hyprexpo = {
          # bind: "$mainMod, TAB, hyprexpo:expo, toggle"
          columns = 2;
          gap_size = 16;
          bg_col = "rgb(111111)";

          workspace_method = "first 1"; # [center/first] [workspace] e.g. first 1 or center m+1
          enable_gesture = false; # laptop -> true
          gesture_fingers = 3;
          gesture_distance = 300;
          gesture_positive = true;
        };
      };
    };
}
