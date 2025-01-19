{
  config,
  lib,
  ...
}:

let
  enabled = config.hom.wayland-wm.panel.waybar.enable;

  inherit (lib) mkIf;
in
{
  config = mkIf enabled {
    home.file = {
      "${config.xdg.configHome}/waybar/scripts" = {
        source = ./scripts;
        recursive = true;
        executable = true;
      };
    };
  };
}
