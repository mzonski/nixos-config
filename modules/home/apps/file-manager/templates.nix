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
  cfg = config.hom.apps.file-manager;
in
{
  options.hom.apps.file-manager = {
    templates = mkBoolOpt false;
  };

  config = mkIf cfg.templates {
    home.file."Templates" = {
      source = ./templates;
      recursive = true;
    };
  };
}
