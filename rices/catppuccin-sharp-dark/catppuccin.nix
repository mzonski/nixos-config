{ inputs, delib, ... }:
delib.rice {
  name = "catppuccin-sharp-dark";

  home = {
    imports = [
      inputs.catppuccin.homeModules.catppuccin
    ];

    catppuccin = {
      enable = true;
      flavor = "mocha";
      cursors.enable = false;
      cursors.flavor = "mocha";

      kvantum.enable = false;
      kvantum.apply = false;

      kitty.enable = true;
      zsh-syntax-highlighting.enable = true;

      gtk = {
        enable = false;
        gnomeShellTheme = false;

        icon.enable = false;

        tweaks = [ "normal" ];
      };
    };
  };
}
