{
  config,
  lib',
  ...
}:

let
  cfg = config.programs.file-manager;

  inherit (lib') mkBoolOpt mkEnumOpt;
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
