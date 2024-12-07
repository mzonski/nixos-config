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
  cfg = config.hom.development;
in
{
  options.hom.development = {
    node = mkBoolOpt false;
  };

  config = mkIf cfg.node {
    home.packages = with pkgs; [
      nodejs_22
      node-gyp
      node-glob
    ];
  };
}
