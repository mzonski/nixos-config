{
  config,
  lib,
  pkgs,
  lib',
  ...
}:

with lib;
with lib';
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
