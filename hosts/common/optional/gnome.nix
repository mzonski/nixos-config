{
  inputs,
  config,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    dconf
    libnotify
    gnome-terminal
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
