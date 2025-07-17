{
  delib,
  pkgs,
  host,
  ...
}:
let
  inherit (delib) singleEnableOption module;
in
module {
  name = "programs.jetbrains";

  options = singleEnableOption host.isDesktop;

  home.ifEnabled = {
    home.packages = with pkgs.jetbrains; [
      webstorm
      pycharm-professional
      rust-rover
      datagrip
      clion
    ];
    # https://youtrack.jetbrains.com/issue/IJPL-2176/File-watcher-failed-to-start-table-error-collision-messages-in-the-log#focus=Comments-27-11108420.0-0
    # Fixes: Watcher terminated with exit code 3 // table error: collision
    home.file."idea.properties".text =
      "idea.filewatcher.executable.path = ${pkgs.fsnotifier}/bin/fsnotifier";
  };
}
