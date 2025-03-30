{
  delib,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (delib) module singleEnableOption;
in
module {
  name = "hardware.audio";

  options = singleEnableOption false;

  myconfig.ifEnabled.user.groups = [ "audio" ];

  nixos.ifEnabled =
    { myconfig, ... }:
    let
      bluetoothEnabled = myconfig.hardware.bluetooth.enable;
    in
    {
      security.rtkit.enable = true;
      hardware.pulseaudio = {
        enable = false;
        package = pkgs.pulseaudioFull;
      };

      environment.systemPackages = with pkgs; [
        pavucontrol
        pamixer
      ];

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;

        wireplumber.extraConfig.noSuspension."monitor.alsa.rules" = [
          {
            matches = [ { "node.name" = "~alsa_*"; } ]; # TODO: test bluez_input.* / bluez_output.*
            actions.update-props = {
              "session.suspend-timeout-seconds" = 0;
              "clock.quantum-limit" = 8192;
              #"dither.method" = "wannamaker3";
              #"dither.noise" = 2;
            };
          }
        ];

        wireplumber.extraConfig.bluetoothEnhancements = mkIf bluetoothEnabled {
          "monitor.bluez.properties" = {
            "bluez5.enable-sbc-xq" = true;
            "bluez5.enable-msbc" = true;
            "bluez5.enable-hw-volume" = true;
            "bluez5.roles" = [
              "a2dp_sink"
              "a2dp_source"
              "bap_sink"
              "bap_source"
              "hsp_hs"
              "hfp_hf"
              "hfp_ag"
            ];
          };
        };
      };
    };
}
