{
  delib,
  lib,
  pkgs,
  ...
}:
let
  inherit (delib) module moduleOptions boolOption;
in
module {
  name = "hardware.bluetooth";

  options = moduleOptions {
    enable = boolOption false;
    restoreConnectedState = boolOption false;
  };

  nixos.ifEnabled =
    { cfg, ... }:
    let
      stateFile = "/run/bluetooth-resume-reconnect.devices";

      captureScript = pkgs.writeShellScript "bt-suspend-capture" ''
        ${pkgs.bluez}/bin/bluetoothctl devices Connected 2>/dev/null \
          | ${pkgs.gawk}/bin/awk '/^Device/ { print $2 }' > ${stateFile} || true
        ${pkgs.bluez}/bin/bluetoothctl power off || true
      '';

      reconnectScript = pkgs.writeShellScript "bt-resume-reconnect" ''
        set -u
        ${pkgs.bluez}/bin/bluetoothctl power on || true
        [ -s ${stateFile} ] || exit 0

        for round in 1 2 3 4 5; do
          pending=0
          while IFS= read -r mac; do
            [ -n "$mac" ] || continue
            if ${pkgs.bluez}/bin/bluetoothctl info "$mac" 2>/dev/null \
                 | ${pkgs.gnugrep}/bin/grep -q 'Connected: yes'; then
              continue
            fi
            pending=1
            ${pkgs.bluez}/bin/bluetoothctl connect "$mac" || true
          done < ${stateFile}
          [ "$pending" -eq 0 ] && break
          delay=$(( 2 ** round ))
          ${pkgs.coreutils}/bin/sleep "$delay"
        done
        ${pkgs.coreutils}/bin/rm -f ${stateFile}
      '';

      sleepTargets = [
        "sleep.target"
        "suspend.target"
        "hybrid-sleep.target"
        "suspend-then-hibernate.target"
      ];
    in
    {
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings = {
          Policy = {
            AutoEnable = true;
          };
        };
      };

      systemd.services = lib.mkIf cfg.restoreConnectedState {
        bluetooth-suspend-capture = {
          description = "Capture connected Bluetooth devices before sleep";
          before = sleepTargets;
          wantedBy = sleepTargets;
          serviceConfig = {
            Type = "oneshot";
            ExecStart = captureScript;
          };
        };

        bluetooth-resume-reconnect = {
          description = "Reconnect Bluetooth devices after resume";
          after = sleepTargets;
          wantedBy = sleepTargets;
          serviceConfig = {
            Type = "oneshot";
            ExecStart = reconnectScript;
            TimeoutStartSec = 180;
          };
        };
      };
    };
}
