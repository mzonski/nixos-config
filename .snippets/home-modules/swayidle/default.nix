{
  pkgs,
  lib,
  mylib,
  config,
  ...
}:
with mylib;
with lib;
let
  swaylock = "${config.programs.swaylock.package}/bin/swaylock";
  pgrep = "${pkgs.procps}/bin/pgrep";
  hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";
  notify-send = "${pkgs.libnotify}/bin/notify-send";

  isLocked = "${pgrep} -x ${swaylock}";

  wallpaper = config.hom.theme.wallpaper;
  enabled = config.hom.wayland-wm.hyprland.enable;
  lockTime = config.hom.wayland-wm.hyprland.lockTime;

  # Makes two timeouts: one for when the screen is not locked (lockTime+timeout) and one for when it is.
  afterLockTimeout =
    {
      timeout,
      command,
      resumeCommand ? null,
    }:
    [
      {
        timeout = lockTime + timeout;
        inherit command resumeCommand;
      }
      {
        command = "${isLocked} && ${command}";
        inherit resumeCommand timeout;
      }
    ];
in
{
  options.hom.wayland-wm.hyprland = {
    lockTime = mkNumOpt 300;
  };

  config = mkIf enabled {

    # sway-audio-idle-inhibit

    services.swayidle = {
      enable = true;
      systemdTarget = "graphical-session.target";
      events = [
        {
          event = "before-sleep";
          command = "${swaylock} -f -i ${wallpaper}"; # Force lock before sleep
        }
        {
          event = "after-resume";
          command = "${hyprctl} dispatch dpms on"; # Ensure screen is on after resume
        }
      ];
      timeouts =
        [
          {
            timeout = lockTime - 60; # 1 minute before lock
            command = "${notify-send} 'Screen Lock' 'Screen will lock in 1 minute'";
          }
          {
            timeout = lockTime;
            command = "${swaylock} -i ${wallpaper} --daemonize --grace 15 --grace-no-mouse";
          }
        ]
        ++ (afterLockTimeout {
          timeout = 60; # + 1 minute
          command = "${hyprctl} dispatch dpms off";
          resumeCommand = "${hyprctl} dispatch dpms on";
        })
        ++ (afterLockTimeout {
          timeout = 600; # +10 minutes
          command = "systemctl suspend";
        });
    };
  };

}
