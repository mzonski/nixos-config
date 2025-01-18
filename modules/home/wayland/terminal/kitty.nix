{
  config,
  lib,
  pkgs,
  lib',
  ...
}:

with lib;
with lib';
let
  enabled = config.programs.kitty.enable;
  zshEnabled = config.programs.zsh.enable;
  fontProfile = config.hom.theme.fontProfiles.monospace;
in
{
  config = mkIf enabled {
    programs.kitty = {
      package = pkgs.kitty;
      shellIntegration.enableZshIntegration = zshEnabled;
      font = {
        size = fontProfile.size;
        name = fontProfile.name;
      };
    };

    commands.runTerminal = "${pkgs.kitty}/bin/kitty";

    # xdg.desktopEntries = {
    #   kitty = {
    #     name = "Kitty";
    #     genericName = "Terminal";
    #     exec = "kitty";
    #     terminal = false;
    #     categories = [
    #       "System"
    #       "TerminalEmulator"
    #     ];
    #   };
    # };

    xdg.mimeApps = {
      associations.added = {
        "x-scheme-handler/terminal" = "kitty.desktop";
      };
      defaultApplications = {
        "x-scheme-handler/terminal" = "kitty.desktop";
      };
    };

    # xdg.terminal-exec.default = [ "kitty.desktop" ];
  };
}
