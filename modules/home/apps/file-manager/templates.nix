{
  config,
  lib,
  mylib,
  ...
}:

with lib;
with mylib;
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
