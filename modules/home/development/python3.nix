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
    python3 = mkBoolOpt false;
  };

  config = mkIf cfg.python3 {
    home.packages = with pkgs; [
      python312
      python312Packages.pip
    ];
  };
}
