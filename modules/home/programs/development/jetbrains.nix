{
  config,
  lib,
  pkgs,
  lib',
  ...
}:

let
  enabled = config.hom.development.jetbrains.toolbox;

  inherit (lib') mkBoolOpt;
  inherit (lib) mkIf;
in
{
  options.hom.development.jetbrains = {
    toolbox = mkBoolOpt false;
  };

  config = mkIf enabled {
    home.packages = with pkgs.unstable.jetbrains; [
      webstorm
      pycharm-professional
      rust-rover
      datagrip
    ];
    # https://youtrack.jetbrains.com/issue/IJPL-2176/File-watcher-failed-to-start-table-error-collision-messages-in-the-log#focus=Comments-27-11108420.0-0
    # Fixes: Watcher terminated with exit code 3 // table error: collision
    home.file."idea.properties".text =
      "idea.filewatcher.executable.path = ${pkgs.fsnotifier}/bin/fsnotifier";

  };
}
