{ inputs, delib, ... }:

let
  inherit (delib) module singleEnableOption;
in
module {
  name = "programs.desktop.figma";

  options = singleEnableOption false;

  nixos.always = {
    imports = [ inputs.figma-linux-next.nixosModules.default ];

  };

  nixos.ifEnabled = {
    programs.figma-linux-next.enable = true;
  };
}
