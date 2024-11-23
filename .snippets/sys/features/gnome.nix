{
  inputs,
  config,
  pkgs,
  ...
}:

# let
#   catppuccin-qt5ct = (
#     pkgs.catppuccin-qt5ct.override {
#       flavour = [ "mocha" ];
#       accents = [ "maroon" ];
#     }
#   );

# in
{
  environment.systemPackages = with pkgs; [
    dconf
    libnotify
    gnome-terminal
    adwaita-qt
    catppuccin-qt5ct
  ];

  environment.gnome.excludePackages = (
    with pkgs;
    [
      xterm
      gnome-console
      gnome-photos
      gnome-tour
      cheese # webcam tool
      gnome-music
      epiphany # web browser
      geary # email reader
      evince # document viewer
      gnome-characters
      totem # video player
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
      gnome-weather
      gnome-maps
    ]
  );

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

  services.gnome.core-utilities.enable = true;
  services.udev.packages = with pkgs; [ gnome-settings-daemon ];

  services = {
    xserver = {
      enable = true;
      desktopManager.gnome.enable = true;

      displayManager.gdm.enable = true;
      displayManager.gdm.autoSuspend = true;
    };

    # Auto Login Configuration
    displayManager.autoLogin.enable = true;
    displayManager.autoLogin.user = "zonni";
  };

  # GNOME Autologin Workaround
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Fix broken stuff
  services.avahi.enable = false;
  networking.networkmanager.enable = false;
}
