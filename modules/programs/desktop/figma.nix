{ inputs, delib, ... }:

let
  inherit (delib) module singleEnableOption;
in
module {
  name = "programs.desktop.figma";

  options = singleEnableOption false;

  nixos.always = {
    imports = [ inputs.nixos-extra.nixosModules.figma-linux-next ];

  };

  nixos.ifEnabled = {
    programs.figma-linux-next.enable = true;
  };
}
