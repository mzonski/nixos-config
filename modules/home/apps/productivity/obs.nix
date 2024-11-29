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
  cfg = config.hom.apps.productivity;
in
{
  options.hom.apps.productivity = {
    obs = mkBoolOpt false;
  };

  config = mkIf cfg.obs {
    programs.obs-studio = {
      enable = true;
      package = pkgs.obs-studio;
      plugins = with pkgs; [
        obs-studio-plugins.wlrobs
        obs-studio-plugins.obs-pipewire-audio-capture

        obs-studio-plugins.input-overlay
        # obs-studio-plugins.obs-vertical-canvas (to enable, broken atm)

        #obs-studio-plugins.obs-source-switcher
        #obs-studio-plugins.obs-backgroundremoval
        #obs-studio-plugins.obs-composite-blur
        #obs-studio-plugins.obs-scale-to-sound
      ];
    };
  };
}
