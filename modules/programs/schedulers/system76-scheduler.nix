{ delib, host, ... }:
let
  inherit (delib) module boolOption;
in
module {
  name = "programs.scheduler.system76";

  options.programs.scheduler.system76 = {
    enable = boolOption host.isDesktop;
  };

  nixos.ifEnabled =
    { cfg, ... }:
    {
      services.system76-scheduler = {
        enable = true;
      };
    };
}
