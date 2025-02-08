{ delib, ... }:
delib.module {
  name = "hardware.audio";
  feature = "noisy-no-alsa-suspension";

  nixos.ifFeatured.services.pipewire.wireplumber.extraConfig.noisyNoSuspension = {
    "monitor.alsa.rules" = [
      {
        matches = [ { "node.name" = "~alsa_*"; } ]; # TODO: test bluez_input.* / bluez_output.*
        actions.update-props = {
          session.suspend-timeout-seconds = 0;
          dither.method = "wannamaker3";
          dither.noise = 2;
        };
      }
    ];
  };
}
