{
  config,
  lib,
  pkgs,
  mylib,
  ...
}:

with lib;
with mylib;
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
        "x-scheme-handler/terminal" = "Kitty.desktop";
      };
      defaultApplications = {
        "x-scheme-handler/terminal" = "Kitty.desktop";
      };
    };
  };
}
