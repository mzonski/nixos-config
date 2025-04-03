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
      package = pkgs.hyprFlake.hyprland;
      portalPackage = pkgs.hyprFlake.xdg-desktop-portal-hyprland;
    };
  };
in
delib.module {
  name = "programs.hyprland";

  nixos.ifEnabled =
    { cfg, ... }:
    let
      inherit (cfg) source;
    in
    {
      programs.hyprland = {
        inherit (hyprlandPkgVariant.${source}) package portalPackage;
      };
    };

  home.ifEnabled =
    { cfg, ... }:
    let
      hyprPkgs = hyprlandPkgVariant.${cfg.source};
    in
    {
      xdg.portal.extraPortals = [ hyprPkgs.portalPackage ];
      wayland.windowManager.hyprland = {
        inherit (hyprPkgs) package;
      };
    };
}
