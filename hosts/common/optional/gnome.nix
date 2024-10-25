{
  services = {
    xserver = {
      enable = true;
      desktopManager.gnome.enable = true;

      displayManager.gdm.enable = true;
      displayManager.gdm.autoSuspend = false;
    };

    gnome.games.enable = true;

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
