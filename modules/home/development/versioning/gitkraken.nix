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
  cfg = config.hom.development.versioning;
in
{
  options.hom.development.versioning = {
    gitkraken = mkBoolOpt false;
  };

  config = mkIf cfg.gitkraken {

    home.packages = (
      with pkgs;
      [
        gitkraken
      ]
    );
  };
}
