{
  config,
  lib,
  pkgs,
  lib',
  ...
}:
let
  enabled = config.programs.peazip.enable;
  inherit (lib') mkBoolOpt;
  inherit (lib) mkIf;
in
{
  options.programs.peazip = {
    enable = mkBoolOpt false;
  };

  config = mkIf enabled (
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
