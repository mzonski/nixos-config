{
  config,
  lib,
  lib',
  ...
}:

let
  enabled = config.features.autologin.enable;
  inherit (config.host) admin;
  inherit (lib) mkIf;
  inherit (lib') mkBoolOpt;
in
{
  options.features.autologin = {
    enable = mkBoolOpt false;
  };

  config = mkIf enabled {
    services.displayManager = {
      autoLogin.enable = true;
      autoLogin.user = admin;

      sddm.settings = {
        Autologin = {
          Relogin = false;
          Session = "hyprland";
          User = admin;
        };
      };
    };

    # GNOME Autologin Workaround
    systemd.services."getty@tty1".enable = false;
    systemd.services."autovt@tty1".enable = false;
  };
}
