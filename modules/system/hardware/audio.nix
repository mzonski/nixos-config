{
  options,
  config,
  lib,
  pkgs,
  mylib,
  ...
}:

with lib;
with mylib;
let
  cfg = config.sys.hardware.audio;
  bluetoothEnabled = config.hardware.bluetooth.enable;
in
{
  options.sys.hardware.audio = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {

    security.rtkit.enable = true;
    hardware.pulseaudio = {
      enable = false;
      package = pkgs.pulseaudioFull;
    };

    services.pipewire = {
      enable = true;
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

    sys.user.extraGroups = [ "audio" ];
  };
}
