{ delib, ... }:
delib.overlayModule {
  name = "sudo";
  overlay = final: prev: {
    sudo = prev.sudo.override { withInsults = true; };
  };
}
