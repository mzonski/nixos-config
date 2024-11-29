{
  config,
  lib,
  pkgs,
  mylib,
  ...
}:

with lib;
with mylib;
let
  cfg = config.hom.apps.entertainment;
in
{
  options.hom.apps.entertainment = {
    vlc = mkBoolOpt false;
    streamlink = mkBoolOpt false;
    tauon = mkBoolOpt false;
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
