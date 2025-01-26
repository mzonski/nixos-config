{
  pkgs,
  delib,
  lib,
  ...
}:
delib.module {
  name = "rices";

  options =
    with delib;
    let
      themeOption = {
        name = noDefault (strOption null);
        package = noDefault (packageOption null);
      };

      themeSizeOption = {
        inherit (themeOption) name package;
        size = noDefault (intOption null);
      };

      rice = {
        options = riceSubmoduleOptions // {
          packages = listOfOption package [ ];
          fonts = {
            monospace = themeSizeOption;
            regular = themeSizeOption;
          };
          cursor = themeSizeOption;
          icons = themeOption;
          gtkThemeName = noDefault (strOption null);
          wallpaper = noDefault (pathOption null);
        };
      };
    in
    {
      rice = riceOption rice;
      rices = ricesOption rice;
    };

  home.always =
    { myconfig, ... }:
    {
      assertions = delib.riceNamesAssertions myconfig.rices;
      home.packages = myconfig.rice.packages ++ [
        myconfig.rice.fonts.monospace.package
        myconfig.rice.fonts.regular.package
        myconfig.rice.cursor.package
      ];
    };
}
