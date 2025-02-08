{
  delib,
  pkgs,
  host,
  ...
}:

let
  inherit (delib) module featuresEnableOption;
in
module {
  name = "hardware.audio";

  options = featuresEnableOption host.isDesktop [ ];

  myconfig.ifEnabled.user.groups = [ "audio" ];

  nixos.ifEnabled = {
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
  };
}
