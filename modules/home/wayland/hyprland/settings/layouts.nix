{
  config,
  lib,
  ...
}:

let
  enabled = config.hom.wayland-wm.hyprland.enable;

  inherit (lib) mkIf;
in
{
  config = mkIf enabled {
    wayland.windowManager.hyprland.settings = {
      dwindle = {
        #no_gaps_when_only = true;
        force_split = 0;
        special_scale_factor = 1.0;
        split_width_multiplier = 1.0;
        use_active_for_splits = true;
        pseudotile = "yes";
        preserve_split = "yes";
      };

      master = {
        new_status = "master";
        special_scale_factor = 1;
        #no_gaps_when_only = false;
      };
    };
  };
}
