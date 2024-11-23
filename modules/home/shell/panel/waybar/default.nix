{
  inputs,
  config,
  options,
  lib,
  pkgs,
  mylib,
  ...
}:

with lib;
with mylib;
let
  enabled = config.hom.shell.panel.waybar.enable;
in
{
  options.hom.shell.panel.waybar = {
    enable = mkBoolOpt false;
  };

  config = mkIf enabled {
    programs.waybar = {
      enable = true;
      package = pkgs.waybar.overrideAttrs (oa: {
        mesonFlags = (oa.mesonFlags or [ ]) ++ [ "-Dexperimental=true" ];
      });
    };
  };
}
# programs.waybar.enable	Whether to enable Waybar.	boolean
# programs.waybar.package	Waybar package to use. Set to `null` to use the default package. 	package
# programs.waybar.settings	Configuration for Waybar, see <https://github.com/Alexays/Waybar/wiki/Configuration> for supported values. 	(list of (JSON value)) or attribute set of (JSON value)
# programs.waybar.style	CSS style of the bar. See <https://github.com/Alexays/Waybar/wiki/Configuration> for the documentation. If the value is set to a path literal, then the path will be used as the css file. 	null or path or strings concatenated with "\n"
# programs.waybar.systemd.enable	Whether to enable Waybar systemd integration.	boolean
# programs.waybar.systemd.target	The systemd target that will automatically start the Waybar service. When setting this value to `"sway-session.target"`, make sure to also enable {option}`wayland.windowManager.sway.systemd.enable`, otherwise the service may never be started. 	string
