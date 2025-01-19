{
  config,
  lib,
  ...
}:

let
  enabled = config.programs.file-manager.enable;

  inherit (lib) mkIf;
in
{
  config = mkIf enabled {
    home.file."Templates" = {
      source = ./templates;
      recursive = true;
    };
  };
}
