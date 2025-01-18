{
  config,
  options,
  lib,
  pkgs,
  lib',
  ...
}:

with lib;
with lib';
let
  cfg = config.hom.theme.catpuccin;
in
{
  options.hom.theme.catpuccin = {
    enable = mkBoolOpt true;
  };

  config = mkIf cfg.enable {
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
