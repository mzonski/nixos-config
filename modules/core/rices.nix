{ delib, ... }:
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
            sans = themeSizeOption;
            emoji = themeSizeOption;
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
      home.packages = myconfig.rice.packages;
    };
}
