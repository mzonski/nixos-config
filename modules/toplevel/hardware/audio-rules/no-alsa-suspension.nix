{ delib, ... }:
delib.module {
  name = "hardware.audio";
  feature = "no-alsa-suspension";

  nixos.ifFeatured.services.pipewire.wireplumber.extraConfig.noSuspension = {
    "monitor.alsa.rules" = [
      {
        matches = [ { "node.name" = "~alsa_*"; } ];
        actions.update-props = {
          session.suspend-timeout-seconds = 0;
        };
      }
    ];
  };
}
