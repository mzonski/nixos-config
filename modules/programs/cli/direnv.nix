{ delib, ... }:

let
  inherit (delib) module singleEnableOption;
in
module {
  name = "programs.cli.direnv";

  options = singleEnableOption true;

  home.ifEnabled.programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
