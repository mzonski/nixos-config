{
  delib,
  pkgs,
  ...
}:
let
  hyprlandPkgVariant = {
    stable = {
      package = pkgs.hyprland;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
    };
    unstable = {
      package = pkgs.unstable.hyprland;
      portalPackage = pkgs.unstable.xdg-desktop-portal-hyprland;
    };
    input = {
      package = pkgs.hyprland.hyprland;
      portalPackage = pkgs.hyprland.xdg-desktop-portal-hyprland;
    };
  };
in
delib.module {
  name = "programs.wayland";

  nixos.ifEnabled =
    { cfg, ... }:
    let
      inherit (cfg.hyprland) source;
    in
    {
      programs.hyprland = {
        inherit (hyprlandPkgVariant.${source}) package portalPackage;
      };
    };

  home.ifEnabled =
    { cfg, ... }:
    let
      hyprPkgs = hyprlandPkgVariant.${cfg.hyprland.source};
    in
    {
      xdg.portal.extraPortals = [ hyprPkgs.portalPackage ];
      wayland.windowManager.hyprland = {
        inherit (hyprPkgs) package;
      };
    };
}
