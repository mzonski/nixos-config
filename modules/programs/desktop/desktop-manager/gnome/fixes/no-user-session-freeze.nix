# https://forums.developer.nvidia.com/t/trouble-suspending-with-510-39-01-linux-5-16-0-freezing-of-tasks-failed-after-20-009-seconds/200933/12
{
  delib,
  lib,
  pkgs,
  ...
}:
let
  inherit (delib) module;
in
module {
  name = "programs.gnome.noUserSessionFreeze";

  nixos.ifEnabled = {

    systemd.package = pkgs.unstable.systemd;

    # boot.kernelParams = [
    #   "freezer.no_user_freeze=1" # Prevents the freezer cgroup from freezing user processes
    # ];

    # # https://github.com/kachick/dotfiles/issues/959#issuecomment-2533264029
    systemd.services.systemd-suspend.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";

    systemd.services.nvidia-hibernate.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
    systemd.services.nvidia-suspend.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
    systemd.services.pre-sleep.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
    systemd.services.post-resume.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
    systemd.services.systemd-hibernate-clear.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
    systemd.services.systemd-hibernate.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
    systemd.services.systemd-hybrid-sleep.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
    systemd.services.systemd-suspend-then-hibernate.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS =
      "false";

    # systemd.sleep.extraConfig = ''
    #   SuspendState=freeze
    # '';

    # # https://gitlab.archlinux.org/archlinux/packaging/packages/nvidia-utils/-/commit/b9ddd997381f9552131862320dcc8c4b45a60708#note_192390
    systemd.services.homed-hibernate.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
    systemd.services.homed-hybrid-sleep.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
    systemd.services.homed-suspend-then-hibernate.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS =
      "false";
  };
}
