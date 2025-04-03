{ delib, pkgs, ... }:

let
  inherit (delib) module;
in
module {
  name = "programs.wayland";

  home.ifEnabled = {
    programs.waybar = {
      enable = true;
      systemd.enable = true;
      systemd.target = "hyprland-session.target";
      package = pkgs.unstable.waybar;
      # package = pkgs.waybar.overrideAttrs (oa: {
      #   mesonFlags = (oa.mesonFlags or [ ]) ++ [ "-Dexperimental=true" ];
      # });
    };
  };
}
