{
  delib,
  lib,
  pkgs,
  host,
  ...
}:

let

  inherit (lib) mkIf;
  inherit (delib) module singleEnableOption;
in
module {
  name = "hardware.audio";

  options = singleEnableOption host.isDesktop;

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
      };

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
    };
}
