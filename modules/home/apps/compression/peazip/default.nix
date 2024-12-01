{
  config,
  options,
  packages,
  lib,
  pkgs,
  mylib,
  ...
}:

with lib;
with mylib;
let
  cfg = config.hom.apps;
in
{
  options.hom.apps = {
    compression = mkBoolOpt false;
  };

  config = mkIf cfg.compression (
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
