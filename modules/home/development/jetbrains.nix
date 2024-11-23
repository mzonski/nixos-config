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
  cfg = config.hom.development.jetbrains;
in
{
  options.hom.development.jetbrains = {
    webstorm = mkBoolOpt false;
    pycharm-professional = mkBoolOpt false;
    datagrip = mkBoolOpt false;
  };

  config = {
    home.packages =
      with pkgs;
      flatten (
        map (
          toolName:
          optionalAttrs (cfg.${toolName}) (
            lib.getAttrFromPath [
              "jetbrains"
              toolName
            ] pkgs
          )
        ) (attrNames cfg)
      );
  };
}
