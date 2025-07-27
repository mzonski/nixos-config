{ host, delib, ... }:

let
  inherit (delib) module singleEnableOption;
in
module {
  name = "programs.cli.direnv";

  options = singleEnableOption host.isDesktop;

  home.ifEnabled.programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
