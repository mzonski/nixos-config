{
  delib,
  pkgs,
  inputs,
  ...
}:

let
  inherit (delib) module singleEnableOption;
in
module {
  name = "services.deepcool-digital-linux";

  options = singleEnableOption false;

  nixos.always.imports = [
    inputs.deepcool-digital-linux.nixosModules.default
  ];

  nixos.ifEnabled =
    { cfg, ... }:
    {
      hardware.deepcool-digital-linux = {
        enable = true;
        systemd = {
          enable = true;
          mode = "cpu_freq";
          updateMs = 2000;
        };
      };
    };
}
