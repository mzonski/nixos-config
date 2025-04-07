# https://forums.developer.nvidia.com/t/trouble-suspending-with-510-39-01-linux-5-16-0-freezing-of-tasks-failed-after-20-009-seconds/200933/12
{ delib, pkgs, ... }:
let
  inherit (pkgs) writeScript;
  inherit (delib) module;
in
module {
  name = "programs.gnome.freezeOnNvidiaSuspend";

  nixos.ifEnabled =
    { cfg, ... }:
    let
      script = writeScript "fix-gnome.sh" ''
        #!${pkgs.bash}/bin/bash
        case "$1" in
            suspend)
                ${pkgs.coreutils}/bin/kill -STOP $(${pkgs.procps}/bin/pgrep -f "bin/gnome-shell")
                ;;
            resume)
                ${pkgs.coreutils}/bin/kill -CONT $(${pkgs.procps}/bin/pgrep -f "bin/gnome-shell")
                ;;
        esac
      '';
    in
    {
      systemd.services.gnome-shell-suspend = {
        description = "Suspend gnome-shell";
        wantedBy = [
          "systemd-suspend.service"
          "systemd-hibernate.service"
        ];
        before = [
          "systemd-suspend.service"
          "systemd-hibernate.service"
          "nvidia-suspend.service"
          "nvidia-hibernate.service"
        ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.bash}/bin/bash ${script} suspend";
        };
      };

      systemd.services.gnome-shell-resume = {
        description = "Resume gnome-shell";
        wantedBy = [
          "systemd-suspend.service"
          "systemd-hibernate.service"
        ];
        after = [
          "systemd-suspend.service"
          "systemd-hibernate.service"
          "nvidia-resume.service"
        ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.bash}/bin/bash ${script} resume";
        };
      };
    };
}
