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

  codecPackages = with pkgs; [
    # Video/Audio data composition framework tools like "gst-inspect", "gst-launch" ...
    gst_all_1.gstreamer
    # Common plugins like "filesrc" to combine within e.g. gst-launch
    gst_all_1.gst-plugins-base
    # Specialized plugins separated by quality
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    # Plugins to reuse ffmpeg to play almost every video format
    gst_all_1.gst-libav
    # Support the Video Audio (Hardware) Acceleration API
    gst_all_1.gst-vaapi
  ];
in
{
  options.sys.hardware.audio = {
    enable = mkBoolOpt false;
    codecs = mkBoolOpt true;
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

    environment.systemPackages =
      with pkgs;
      [
        pavucontrol
        pamixer
      ]
      ++ lib.optionals cfg.codecs codecPackages;

    environment.sessionVariables = mkIf cfg.codecs {
      GST_PLUGIN_SYSTEM_PATH = "${pkgs.gst_all_1.gst-plugins-base}/lib/gstreamer-1.0/:${pkgs.gst_all_1.gst-plugins-good}/lib/gstreamer-1.0/";
      PATH = "$PATH:${pkgs.gst_all_1.gstreamer}/bin";
      # PATH = "$PATH:${gst_all_1.gstreamer.dev}/bin";
    };

    sys.user.extraGroups = [ "audio" ];
  };
}
