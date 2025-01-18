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
    python3 = mkBoolOpt false;
  };

  config = mkIf cfg.python3 {
    home.packages = with pkgs; [
      python312
      python312Packages.pip
      python312Packages.packaging
      python312Packages.requests
      python312Packages.xmltodict
    ];
  };
}
