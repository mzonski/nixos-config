{
  config,
  lib,
  pkgs,
  lib',
  ...
}:

let
  cfg = config.hom.development;

  inherit (lib') mkBoolOpt;
  inherit (lib) mkIf;
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
