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
  enabled = config.hom.development.jetbrains.toolbox;
in
{
  options.hom.development.jetbrains = {
    toolbox = mkBoolOpt false;
  };

  config = mkIf enabled {
    home.packages = with pkgs; [
      jetbrains-toolbox
    ];
  };
}
