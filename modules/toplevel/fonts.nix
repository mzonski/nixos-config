{
  delib,
  host,
  ...
}:
delib.module {
  name = "font.desktop.config";

  options = delib.singleEnableOption host.not.isMinimal;

  home.ifEnabled =
    { myconfig, ... }:
    {
      home.packages = [
        myconfig.rice.fonts.monospace.package
        myconfig.rice.fonts.regular.package
        myconfig.rice.cursor.package
      ];
    };
}
