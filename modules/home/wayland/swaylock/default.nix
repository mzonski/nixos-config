{
  pkgs,
  lib,
  lib',
  config,
  ...
}:
with lib';
with lib;
let
  enabled = config.hom.wayland-wm.hyprland.enable && config.hom.wayland-wm.idle.lockEnabled;
  fontProfile = config.hom.theme.fontProfiles.regular;
in
{
  config = mkIf enabled {

    programs.swaylock = {
      enable = true;
      package = pkgs.swaylock-effects;
      settings = {
        clock = true;
        #datestr = "";
        screenshots = true;

        effect-blur = "20x3";
        effect-vignette = "0.5:0.5";
        effect-pixelate = 5;
        fade-in = 0.1;

        font = fontProfile.name;
        font-size = fontProfile.size + 3;

        line-uses-inside = true;
        disable-caps-lock-text = true;
        indicator = true;
        indicator-caps-lock = true;
        indicator-radius = 40;
        indicator-idle-visible = true;
        indicator-y-position = 1000;

        color = "1e1e2e";
        bs-hl-color = "f5e0dc";
        key-hl-color = "a6e3a1";
        caps-lock-bs-hl-color = "f5e0dc";
        caps-lock-key-hl-color = "a6e3a1";
        ring-color = "b4befe";
        ring-clear-color = "f5e0dc";
        ring-caps-lock-color = "fab387";
        ring-ver-color = "89b4fa";
        ring-wrong-color = "eba0ac";
        text-color = "cdd6f4";
        text-clear-color = "f5e0dc";
        text-caps-lock-color = "fab387";
        text-ver-color = "89b4fa";
        text-wrong-color = "eba0ac";
        layout-text-color = "cdd6f4";

        inside-color = "00000000";
        inside-clear-color = "00000000";
        inside-caps-lock-color = "00000000";
        inside-ver-color = "00000000";
        inside-wrong-color = "00000000";
        layout-bg-color = "00000000";
        layout-border-color = "00000000";
        line-color = "00000000";
        line-clear-color = "00000000";
        line-caps-lock-color = "00000000";
        line-ver-color = "00000000";
        line-wrong-color = "00000000";
        separator-color = "00000000";
      };
    };
  };

}
