{ delib, ... }:
delib.module {
  name = "hardware.bluetooth";

  nixos.ifEnabled.services.pipewire.wireplumber.extraConfig.bluetoothEnhancements = {
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
}
