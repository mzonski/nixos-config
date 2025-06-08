{ delib, host, ... }:
delib.module {
  name = "font.desktop.config";

  options = delib.singleEnableOption host.isDesktop;

  nixos.ifEnabled =
    { myconfig, ... }:
    {
      fonts.fontconfig = {
        enable = true;
        includeUserConf = true;

        allowBitmaps = true;
        allowType1 = false;
        useEmbeddedBitmaps = true;
        cache32Bit = false;
        antialias = true;

        hinting = {
          enable = false;
          autohint = false;
          style = "none";
        };

        subpixel = {
          rgba = "none";
          lcdfilter = "none";
        };

        defaultFonts = {
          serif = [ myconfig.rice.fonts.sans.name ];
          sansSerif = [ myconfig.rice.fonts.sans.name ];
          monospace = [ myconfig.rice.fonts.monospace.name ];
          emoji = [ myconfig.rice.fonts.emoji.name ];
        };
      };

      environment.systemPackages = [
        myconfig.rice.fonts.monospace.package
        myconfig.rice.fonts.sans.package
        myconfig.rice.fonts.emoji.package
        myconfig.rice.cursor.package
      ];
    };
}
