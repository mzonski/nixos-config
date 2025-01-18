{
  config,
  lib,
  lib',
  ...
}:

with lib;
with lib';
let
  enabled = config.programs.file-manager.enable;
in
{
  config = mkIf enabled {
    home.file."Templates" = {
      source = ./templates;
      recursive = true;
    };
  };
}
