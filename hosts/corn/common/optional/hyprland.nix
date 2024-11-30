{ pkgs, config, ... }:
let
  inherit (config.sys) username;
in
{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.systemPackages = with pkgs; [
    waybar
    rofi-wayland
    kitty
  ];

  services = {
    xserver = {
      enable = true;

    };

    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;
    displayManager.sddm.autoNumlock = true;

  };

  networking.networkmanager.enable = false;
}
