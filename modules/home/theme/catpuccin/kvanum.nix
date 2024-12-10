{
  inputs,
  config,
  lib,
  pkgs,
  mylib,
  ...
}:

with lib;
with mylib;

let
  cfg = config.programs.kvantum;
  variant = "mocha";
  accent = "mauve";
  kvantumThemePackage = pkgs.catppuccin-kvantum.override {
    inherit variant accent;
  };
in
{
  # Define options for Kvantum
  options.programs.kvantum = {
    enable = mkBoolOpt' false "Enable Kvantum for Qt applications.";
    theme = mkStrOpt' "KvAdapta" "The Kvantum theme name to use.";
  };

  config = mkIf cfg.enable {
    home.packages = [ kvantumThemePackage ];

    qt = {
      enable = true;
      platformTheme.name = "kvantum";
      style.name = "kvantum";
    };

    xdg.configFile = {
      "Kvantum/kvantum.kvconfig".text = ''
        [General]
        theme=Catppuccin-${variant}-${accent}
      '';

      "Kvantum/Catppuccin-${variant}-${accent}".source =
        "${kvantumThemePackage}/share/Kvantum/Catppuccin-${variant}-${accent}";
    };

    # home.sessionVariables = {
    #   QT_STYLE_OVERRIDE = "kvantum";
    # };

    # # Write a Kvantum config file specifying the theme
    # home.file.".config/Kvantum/kvantum.kvconfig".text = ''
    #   [General]
    #   theme=${cfg.theme}
    # '';
  };
}
