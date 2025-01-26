{
  delib,
  pkgs,
  host,
  ...
}:
let
  inherit (delib) module singleEnableOption;
in
module {
  name = "programs.desktop.obs";

  options = singleEnableOption host.isDesktop;

  home.ifEnabled = {
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

    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-wlr ]; # recording via pipewire
  };
}
