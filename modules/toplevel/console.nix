{ delib, pkgs, ... }:
delib.module {
  name = "toplevel.console";
  nixos.always = {
    console.packages = [ pkgs.terminus_font ];
    console.font = "${pkgs.terminus_font}/share/consolefonts/ter-u24b.psf.gz";
    # Homebrew color scheme @ https://gogh-co.github.io/Gogh/
    console.colors = [
      "000000"
      "990000"
      "00A600"
      "999900"
      "0000B2"
      "B200B2"
      "00A6B2"
      "BFBFBF"
      "666666"
      "E50000"
      "00D900"
      "E5E500"
      "0000FF"
      "E500E5"
      "00E5E5"
      "FFFFFF"
    ];
  };
}
