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
  enabled = config.qt.enable;
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
  config = mkIf enabled {
    home.packages = [ kvantumThemePackage ];

    qt = {
      style.name = "kvantum";
    };

    xdg.configFile = {
      kvantum = {
        target = "Kvantum/kvantum.kvconfig";
        text = lib.generators.toINI { } {
          General = {
            theme = themeName;
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
