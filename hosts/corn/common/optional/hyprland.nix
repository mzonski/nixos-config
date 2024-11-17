{ pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    #nvidiaPatches = true;
    xwayland.enable = true;
  };

  environment.systemPackages = with pkgs; [
    waybar
    libnotify
    eww
    rofi-wayland
    kitty # required for the default cfg
  ];

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # Optional, hint Electron apps to use Wayland:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  qt = {
    enable = true;
    platformTheme = "qt5ct";
    # style = "adwaita-dark";
  };

  environment.sessionVariables = {
    QT_SCALE_FACTOR = 1;
    QT_AUTO_SCREEN_SCALE_FACTOR = 0;
    QT_SCREEN_SCALE_FACTORS = 2;
    #QT_STYLE_OVERRIDE = "adwaita-dark";
    #QT_QPA_PLATFORMTHEME="qt5ct";
  };

  services = {
    xserver = {
      enable = true;

    };

    # Auto Login Configuration
    displayManager.autoLogin.enable = true;
    displayManager.autoLogin.user = "zonni";

    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;
    # displayManager.sddm.theme = "where_is_my_sddm_theme";
  };

  # GNOME Autologin Workaround
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Fix broken stuff
  services.avahi.enable = false;
  networking.networkmanager.enable = false;
}
