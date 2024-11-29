{ pkgs, ... }:
{
  console.packages = [ pkgs.terminus_font ];
  console.font = "${pkgs.terminus_font}/share/consolefonts/ter-u24b.psf.gz";
}
