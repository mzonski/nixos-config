{
  config,
  options,
  lib,
  pkgs,
  mylib,
  ...
}:

with lib;
with mylib;
let
  cfg = config.hom.apps.engineering;
in
{
  options.hom.apps.engineering = {
    qcad = mkBoolOpt false;
  };

  config = {
    home.packages =
      with pkgs;
      flatten (
        map (
          pkgName:
          optionalAttrs (cfg.${pkgName}) (
            lib.getAttrFromPath [
              pkgName
            ] pkgs
          )
        ) (attrNames cfg)
      );
  };
}
