{ delib, ... }:

let
  inherit (delib) module;
in
module {
  name = "programs.hyprland";

  home.ifEnabled = {
    services.gnome-keyring.enable = true;

    xdg.portal = {
      enable = true;
      config.common = {
        default = [
          "hyprland"
          "gtk"
        ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };
    };
  };
}
