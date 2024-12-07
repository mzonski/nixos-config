{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin

    ./packages.nix
    ./programs.nix

    ./global.nix
    #./shell.nix

  ];

  hom = {
    development = {

      jetbrains.toolbox = true;
      node = true;
      rust = false;
      python3 = true;
      vscode.enable = true;
    };

    wayland-wm = {
      hyprland = {
        enable = true;
      };
      panel.waybar.enable = true;
      panel.swaync.enable = true;

      idle = {
        lockEnabled = false;
        lockTimeout = 10 * 60; # 10 min
        turnOffDisplayTimeout = 5 * 60; # 5 min
        suspendTimeout = 30 * 60; # 30 min
      };
    };
    theme = {
      catpuccin.enable = true;
      fontProfiles = {
        enable = true;
        monospace = {
          name = "FiraCode Nerd Font";
          package = pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; };
          size = 12;
        };
        regular = {
          name = "Fira Sans";
          package = pkgs.fira;
        };
      };
      wallpaper = ./wallpaper.png;
    };
  };
}
