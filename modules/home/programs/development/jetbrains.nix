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
    home.packages = with pkgs.jbPkgs.jetbrains; [
      webstorm
      pycharm-professional
      rust-rover
      datagrip
    ];
    # Fixes: Watcher terminated with exit code 3 // table error: collision
    home.file."idea.properties".text =
      "idea.filewatcher.executable.path = ${pkgs.fsnotifier}/bin/fsnotifier";

  };
}
