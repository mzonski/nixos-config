{ delib, lib, ... }:

let
  inherit (delib) module singleEnableOption;
in
module {
  name = "programs.gdm";

  options = singleEnableOption false;

  nixos.ifEnabled =
    { myconfig, ... }:
    {
      services.displayManager.gdm = {
        enable = true;
        wayland = true;
        autoSuspend = false;
        debug = false;

        settings = { };
        autoLogin.delay = 3;
      };

      # https://github.com/gdm-settings/gdm-settings/blob/ff3e7be3bbf5f0da798d0fcd78e227ef8bc3101c/gdms/settings.py#L431
      programs.dconf.profiles.gdm.databases = [
        {
          settings = {
            "org/gnome/mutter" = {
              experimental-features = [ "scale-monitor-framebuffer" ];
            };

            "org/gnome/desktop/interface" = {
              scaling-factor = lib.gvariant.mkUint32 2;
              accent-color = "purple";
            };

            "org/gnome/desktop/sound" = {
              event-sounds = true;
            };
          };
        }
      ];
    };
}
