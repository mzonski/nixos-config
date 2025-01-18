{
  inputs,
  config,
  lib,
  mylib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (mylib) mkEnumOpt;

  enabled = config.windows.variant == "hyprland";
  hyprSource = config.windows.hyprland.source;

  hyprlandPackages = {
    stable = {
      package = pkgs.hyprland;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
    };
    unstable = {
      package = pkgs.unstable.hyprland;
      portalPackage = pkgs.unstable.xdg-desktop-portal-hyprland;
    };
    input = {
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage =
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    };
  };
in
{
  options.windows = {
    hyprland.source = mkEnumOpt [ "stable" "unstable" "input" ] null;
  };

  config = mkIf enabled {
    assertions = [
      {
        assertion = hyprSource != null;
        message = "windows.hyprland.source must be set when using Hyprland";
      }
    ];
    programs.hyprland = {
      inherit (hyprlandPackages.${hyprSource}) package portalPackage;
      enable = true;
      xwayland.enable = true;
    };

    environment.systemPackages = with pkgs; [
      kitty # hyprland default terminal
    ];

    services = {
      xserver.enable = true;
      displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        autoNumlock = true;
      };
    };
  };
}
