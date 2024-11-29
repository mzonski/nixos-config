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
  cfg = config.hom.apps.terminal;
  zshEnabled = config.hom.apps.cli.zsh;
  fontProfile = config.hom.theme.fontProfiles.monospace;
in
{
  options.hom.apps.terminal = {
    kitty = mkBoolOpt false;
  };

  config = mkIf cfg.kitty {
    programs.kitty = {
      enable = true;
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
