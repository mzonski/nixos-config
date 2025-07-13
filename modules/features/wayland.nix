{ host, delib, ... }:

let
  inherit (delib) module singleEnableOption;
in
module {
  name = "features.wayland";

  options = singleEnableOption host.isDesktop;

  nixos.ifEnabled = {
    environment.variables = {
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
    };
  };
}
