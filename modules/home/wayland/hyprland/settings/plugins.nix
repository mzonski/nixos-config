{ config, lib, ... }:
let
  enabled = config.hom.wayland-wm.hyprland.enable;
  regularFont = config.hom.theme.fontProfiles.regular;

  inherit (lib) mkIf;
in
{
  config = mkIf enabled {
    wayland.windowManager.hyprland.settings.plugins = {
      hyprbars = {
        #bar_color = "rgb(ff0000)";
        bar_height = 48;
        #col.text = "rgb(00ff00)";
        # bar_text_size = 22;
        #bar_title_enabled = true;
        #bar_blur = false;
        bar_text_font = regularFont.name;
        #bar_text_align = "left";
        #bar_part_of_window = true;
        #bar_precedence_over_border = true;
        #bar_buttons_alignment = "right";
        #bar_padding = 4;
        #bar_button_padding = 2;

        hyprbars-button = [
          "rgb(0000ff), 24,  󰖭  , hyprctl dispatch killactive"
          "rgb(eeee11), 24,    , hyprctl dispatch fullscreen 1"
        ];
      };

      hyprexpo = {
        # bind: "$mainMod, TAB, hyprexpo:expo, toggle"
        columns = 3;
        gap_size = 5;
        bg_col = "rgb(111111)";

        workspace_method = "center current"; # [center/first] [workspace] e.g. first 1 or center m+1
        enable_gesture = false; # laptop -> true
        gesture_fingers = 3;
        gesture_distance = 300;
        gesture_positive = true;
      };
    };
  };
}
