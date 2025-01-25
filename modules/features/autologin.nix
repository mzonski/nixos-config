{ delib, ... }:

let
  inherit (delib) module singleEnableOption;
in
module {
  name = "features.autologin";

  options = singleEnableOption false;

  nixos.ifEnabled =
    { myconfig, ... }:
    let
      inherit (myconfig.admin) username;
    in
    {
      services.displayManager = {
        autoLogin.enable = true;
        autoLogin.user = username;

        sddm.settings = {
          Autologin = {
            Relogin = false;
            Session = "hyprland"; # TODO: variable
            User = username;
          };
        };
      };

      # TODO: condition
      # GNOME Autologin Workaround
      systemd.services."getty@tty1".enable = false;
      systemd.services."autovt@tty1".enable = false;
    };
}
