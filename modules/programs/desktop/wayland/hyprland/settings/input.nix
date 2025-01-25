{ delib, ... }:
let
  inherit (delib) module;
in
module {
  name = "programs.wayland";

  home.ifEnabled = {
    wayland.windowManager.hyprland.settings.input = {
      kb_layout = "pl";
      kb_options = "grp:alt_caps_toggle";
      numlock_by_default = true;
      follow_mouse = 2;
      float_switch_override_focus = true;
      sensitivity = 0;
      touchpad = {
        natural_scroll = false;
      };
    };
  };
}
