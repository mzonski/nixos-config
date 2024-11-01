{
  services = {
    xserver = {
      enable = true;
      desktopManager.sddm.enable = true;
      desktopManager.plasma6.enable = true;
    };

    # Auto Login Configuration
    displayManager.autoLogin.enable = true;
    displayManager.autoLogin.user = "zonni";
  };
  
  services.displayManager.defaultSession = "plasmax11";

  # GNOME Autologin Workaround
  #systemd.services."getty@tty1".enable = false;
  #systemd.services."autovt@tty1".enable = false;

  # Fix broken stuff
  services.avahi.enable = false;
  networking.networkmanager.enable = false;
}
