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
  cfg = config.programs.kvantum;
  variant = "mocha";
  accent = "mauve";
  kvantumThemePackage = pkgs.catppuccin-kvantum.override {
    inherit variant accent;
  };
  themeSettings = {
    middle_click_scroll = true;
    transparent_pcmanfm_view = true;
    tint_on_mouseover = 10;
    blur_translucent = false;
    lxqtmainmenu_iconsize = 22;
    comment = themeName;
  };
  replaceThemeSettings = lib.concatMapStrings (
    name: "-e 's/${name}=.*/${name}=${toString themeSettings.${name}}/' "
  ) (builtins.attrNames themeSettings);

  themeName = "Catppuccin${capitalize variant}${capitalize accent}Dark";

in
{
  options.programs.kvantum = {
    enable = mkBoolOpt' false "Enable Kvantum for Qt applications.";
    theme = mkStrOpt' "KvAdapta" "The Kvantum theme name to use.";
  };

  config = mkIf cfg.enable {
    home.packages =
      [ kvantumThemePackage ]
      ++ (with pkgs; [
        kdePackages.breeze-icons
        libsForQt5.qt5.qtbase
        libsForQt5.qtstyleplugins
        qt6.qtbase
      ]);

    qt = {
      enable = true;
      platformTheme.name = "kvantum";
      style.name = "kvantum";
    };

    xdg.configFile = {
      kvantum = {
        target = "Kvantum/kvantum.kvconfig";
        text = lib.generators.toINI { } {
          General = {
            theme = themeName;
            icon_theme = "breeze-dark"; # i smell this don't have any effect :/
          };
        };
      };

      "Kvantum/${themeName}".source =
        pkgs.runCommand "patched-kvantum-theme"
          {
            nativeBuildInputs = [ pkgs.gnused ];
          }
          ''
            workdir=$(mktemp -d)
            cp -r ${kvantumThemePackage}/share/Kvantum/catppuccin-${variant}-${accent}/* $workdir/
            mv $workdir/catppuccin-${variant}-${accent}.kvconfig $workdir/${themeName}.kvconfig
            mv $workdir/catppuccin-${variant}-${accent}.svg $workdir/${themeName}.svg
            sed -i ${replaceThemeSettings} "$workdir/${themeName}.kvconfig"

            mkdir -p $out
            cp -r $workdir/* $out/
            rm -rf $workdir
          '';
    };
  };
}
