{
  pkgs,
  delib,
  host,
  ...
}:

let
  inherit (delib) module singleEnableOption;
in
module {
  name = "programs.desktop.kitty";

  options = singleEnableOption host.isDesktop;

  myconfig.ifEnabled.commands.runTerminal = "${pkgs.kitty}/bin/kitty";

  home.ifEnabled =
    { myconfig, ... }:
    {
      programs.kitty = {
        enable = true;
        package = pkgs.kitty;
        shellIntegration.enableZshIntegration = myconfig.programs.cli.zsh.enable;
        font = {
          inherit (myconfig.rice.fonts.monospace) name size;
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
          "x-scheme-handler/terminal" = "kitty.desktop";
        };
        defaultApplications = {
          "x-scheme-handler/terminal" = "kitty.desktop";
        };
      };

      # xdg.terminal-exec.default = [ "kitty.desktop" ];
    };
}
