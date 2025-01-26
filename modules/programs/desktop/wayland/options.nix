{ delib, host, ... }:

let
  inherit (delib) module boolOption intOption;
in
module {
  name = "programs.wayland";

  options.programs.wayland = {
    enable = boolOption host.isDesktop;
    idle = {
      lockEnabled = boolOption false;
      lockTimeout = intOption 660;
      turnOffDisplayTimeout = intOption 600;
      suspendTimeout = intOption 1800;
    };
  };
}
