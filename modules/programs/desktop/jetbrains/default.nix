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

  nixos.ifEnabled = {
    # Jetbrains IDEs still have weak wayland support and cannot idle inhibit/shutdown on reboot
    systemd.services.kill-jetbrains-ides =
      let
        idesToKill = [
          "webstorm"
          "rustrover"
          "datagrip"
          "clion"
          "rider"
          "pycharm"
        ];
      in
      {
        description = "Kill JetBrains IDEs on shutdown";

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStop = pkgs.writeShellScript "kill-ides" ''
            ${pkgs.lib.concatMapStringsSep "\n" (ide: "${pkgs.procps}/bin/pkill -9 ${ide} || true") idesToKill}
          '';
        };

        wantedBy = [ "multi-user.target" ];
        before = [ "shutdown.target" ];
      };
  };

  home.ifEnabled = {
    home.packages = with pkgs.jetbrains; [
      webstorm
      pycharm-professional
      rust-rover
      datagrip
      clion
      rider
    ];

    # https://youtrack.jetbrains.com/issue/IJPL-2176/File-watcher-failed-to-start-table-error-collision-messages-in-the-log#focus=Comments-27-11108420.0-0
    # Fixes: Watcher terminated with exit code 3 // table error: collision
    home.file."idea.properties".text =
      "idea.filewatcher.executable.path = ${pkgs.fsnotifier}/bin/fsnotifier";

  };
}
