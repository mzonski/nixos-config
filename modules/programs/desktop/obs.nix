{
  config,
  lib,
  pkgs,
  ...
}:

let
  enabled = config.programs.obs-studio.enable;

  inherit (lib) mkIf;
in
{
  config = mkIf enabled {
    programs.obs-studio = {
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
