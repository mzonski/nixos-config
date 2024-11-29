{
  pkgs,
  lib,
  mylib,
  config,
  ...
}:
with mylib;
with lib;
let
  enabled = config.hom.wayland-wm.hyprland.enable;
in
{
  config = mkIf enabled {
    services.cliphist = {
      enable = true;
      package = pkgs.cliphist;
      allowImages = true;
      extraOptions = [
        "--max-items 100"
        "--primary"
      ];
    };

    home.packages = with pkgs; [
      wl-clipboard
      wl-clip-persist
    ];
  };
}
