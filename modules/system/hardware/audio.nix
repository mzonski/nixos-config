{
  config,
  lib,
  pkgs,
  mylib,
  ...
}:

with lib;
with mylib;
let
  enabled = config.services.pipewire.enable;
  bluetoothEnabled = config.hardware.bluetooth.enable;
in
{
  config = mkIf enabled {
    security.rtkit.enable = true;
    hardware.pulseaudio = {
      enable = false;
      package = pkgs.pulseaudioFull;
    };

    services.pipewire = {
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    environment.systemPackages = with pkgs; [
      pavucontrol
      pamixer
    ];

    services.pipewire.wireplumber.extraConfig.bluetoothEnhancements = mkIf bluetoothEnabled {
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

    host.user.extraGroups = [ "audio" ];
  };
}
