{ delib, ... }:
let
  inherit (delib)
    listOfOption
    package
    noDefault
    strOption
    packageOption
    intOption
    pathOption
    ;
in
delib.extension {
  name = "extend-rice-options";
  description = "Extends Denix rice options";

  libExtension =
    _: _: prev:
    let
      themeOption = {
        name = noDefault (strOption null);
        package = noDefault (packageOption null);
      };

      themeSizeOption = {
        inherit (themeOption) name package;
        size = noDefault (intOption null);
      };
    in
    {
      riceSubmoduleOptions = prev.riceSubmoduleOptions // {
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
}
