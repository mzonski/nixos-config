{
  delib,
  lib,
  ...
}:
let
  inherit (delib) module;
  inherit (builtins) toString;
in
module {
  name = "programs.gnome";

  home.ifEnabled =
    { cfg, myconfig, ... }:
    let
      inherit (myconfig.rice) wallpaper fonts gtkThemeName;
    in
    {
      dconf = {
        settings = {
          "org/gnome/desktop/interface" = {
            monospace-font-name = "${fonts.monospace.name} ${toString fonts.monospace.size}";
            font-name = "${fonts.sans.name} ${toString fonts.sans.size}";
            color-scheme = "prefer-dark";
            scaling-factor = lib.gvariant.mkUint32 2;
          };
          "org/gnome/desktop/background" = {
            primary-color = "#11111a";
            secondary-color = "#1e1e2e";
            picture-uri = "file://${wallpaper}";
            picture-uri-dark = "file://${wallpaper}";
            picture-options = "zoom";
          };
          "org/gnome/desktop/screensaver" = {
            primary-color = "#11111a";
            secondary-color = "#1e1e2e";
            screensaver = "file://${wallpaper}";
            picture-options = "zoom";
            show-full-name-in-top-bar = false;
            status-message-enabled = false;
            lock-delay = 1200;
          };
          "org/gnome/desktop/wm/preferences" = {
            num-workspaces = 4;
            focus-mode = "click";
            theme = gtkThemeName;
          };
          "org/gnome/shell/extensions/user-theme" = {
            name = gtkThemeName;
          };
        };
      };
    };
}
