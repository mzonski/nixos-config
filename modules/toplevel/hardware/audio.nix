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
              "node.always-process" = true;
              "dither.method" = "wannamaker3";
              "dither.noise" = 2;
            };
          }
        ];

        wireplumber.extraConfig.NVIDIA_HDMI."monitor.alsa.rules" = [
          {
            matches = [ { "node.name" = "alsa_output.pci-0000_01_00.1.hdmi-stereo-extra1"; } ];
            actions.update-props =
              let
                # So much config just to not use PULSE_LATENCY_MSEC=50 variable
                sampleRate = 192000;
                defaultLatencyMs = 50;
                minLatencyMs = 40;
                maxLatencyMs = 100;
                maxLimitMs = 200;

                calcFrames = ms: ms * (sampleRate / 1000);

                defaultFrames = calcFrames (defaultLatencyMs);
                minFrames = calcFrames (minLatencyMs);
                maxFrames = calcFrames (maxLatencyMs);
                maxLimitFrames = calcFrames (maxLimitMs);

                pulseFormat = frames: "${toString frames}/${toString sampleRate}";
              in
              {
                "node.description" = "Speakers";
                "node.latency" = "${toString defaultLatencyMs}/1000";

                "clock.rate" = sampleRate;
                "clock.quantum" = defaultFrames;
                "clock.min-quantum" = minFrames;
                "clock.max-quantum" = maxFrames;
                "clock.quantum-limit" = maxLimitFrames;

                "pulse.min.req" = pulseFormat (minFrames);
                "pulse.default.req" = pulseFormat (defaultFrames);
                "pulse.min.frag" = pulseFormat (minFrames);
                "pulse.default.frag" = pulseFormat (defaultFrames);
                "pulse.default.tlength" = pulseFormat (maxFrames);
                "pulse.default.maxlength" = pulseFormat (maxLimitFrames);
                "pulse.min.quantum" = pulseFormat (minFrames);
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
