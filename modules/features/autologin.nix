{ delib, ... }:

let
  inherit (delib) module boolOption strOption;
in
module {
  name = "features.autologin";

  options.features.autologin = {
    enable = boolOption false;
    session = strOption "hyprland";
  };

  nixos.ifEnabled =
    { cfg, myconfig, ... }:
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
            Session = cfg.session;
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
