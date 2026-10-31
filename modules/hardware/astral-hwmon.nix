{
  delib,
  pkgs,
  ...
}:
let
  inherit (delib) module singleEnableOption;

  chipName = "astral12vhpwr";
in
module {
  name = "hardware.astral-hwmon";

  options = singleEnableOption false;

  nixos.ifEnabled = {
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="hwmon", ATTR{name}=="${chipName}", RUN+="${pkgs.coreutils}/bin/ln -sfn /sys%p /run/hardware/${chipName}"
    '';

    environment.systemPackages = [
      pkgs.local.astral-guard
    ];
  };

  home.ifEnabled =
    let
      notifySend = "${pkgs.libnotify}/bin/notify-send";
      check = pkgs.writeShellScript "astral-guard-check" ''
        report=$(${pkgs.local.astral-guard}/bin/astral-guard --quiet)
        level=$?
        [ -n "$report" ] && echo "$report"

        notify() {
          ${notifySend} \
            --app-name=astral-guard \
            --hint="string:x-kde-origin-name:ROG Astral 5090" \
            "$@"
        }

        warning() {
          notify --urgency=normal --expire-time=55000 \
            --icon=dialog-warning --category=device \
            --hint=string:sound-name:dialog-warning \
            "$@"
        }

        critical() {
          notify --urgency=critical \
            --icon=dialog-error --category=device \
            --hint=string:sound-name:dialog-error-critical \
            "$@"
        }

        # notify on every run while a finding persists
        case "$level" in
          1) warning "12VHPWR WARNING" "$report" ;;
          2) critical "12VHPWR CRITICAL" "$report" ;;
        esac

        exit "$level"
      '';
    in
    {
      systemd.user.services.astral-guard = {
        Unit.Description = "12VHPWR connector guard";
        Service = {
          Type = "oneshot";
          ExecStart = "${check}";
        };
      };

      systemd.user.timers.astral-guard = {
        Unit = {
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Timer = {
          OnActiveSec = "1min";
          OnUnitActiveSec = "1min";
          AccuracySec = "10s";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
}
