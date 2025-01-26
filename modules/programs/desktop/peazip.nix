{
  delib,
  pkgs,
  host,
  ...
}:
let
  inherit (delib) module singleEnableOption;
in
module {
  name = "programs.desktop.peazip";

  options = singleEnableOption host.isDesktop;

  home.ifEnabled = (
    let
      _7zz = (
        pkgs._7zz.override {
          enableUnfree = true;
        }
      );

      peazip = (
        pkgs.peazip-gtk2.override {
          _7zz = _7zz;
        }
      );

    in
    {
      home.packages = [
        peazip
        _7zz
      ];
    }
  );
}
