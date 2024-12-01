{
  config,
  options,
  lib,
  pkgs,
  mylib,
  ...
}:

with lib;
with mylib;
let
  cfg = config.sys.services.autologin;
  inherit (config.sys) username;
in
{
  options.sys.services.autologin = with types; {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {

    services = {

      # Auto Login Configuration
      displayManager.autoLogin.enable = true;
      displayManager.autoLogin.user = "zonni";

      displayManager.sddm.settings = {
        Autologin = {
          Relogin = false;
          Session = "hyprland";
          User = username;
        };
      };
    };

    # GNOME Autologin Workaround
    systemd.services."getty@tty1".enable = false;
    systemd.services."autovt@tty1".enable = false;
  };
}
