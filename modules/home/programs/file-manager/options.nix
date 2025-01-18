{
  config,
  lib,
  lib',
  ...
}:

with lib;
with lib';
let
  cfg = config.programs.file-manager;
in
{
  options.programs.file-manager = {
    enable = mkBoolOpt false;
    app = mkEnumOpt [ "pcmanfm" "thunar" ] null;
  };

  config.assertions = [
    {
      assertion = !cfg.enable || cfg.app != null;
      message = "When file-manager is enabled, an app must be selected";
    }
  ];
}
