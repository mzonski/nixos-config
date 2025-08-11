{
  lib,
  delib,
  inputs,
  ...
}:

let
  inherit (delib) module singleEnableOption;
in
module {
  name = "features.vpnclient";

  options = singleEnableOption false;

  myconfig.ifEnabled.user.groups = [
    "piavpn"
    "piahnsd"
  ];

  nixos.always.imports = [
    inputs.piavpn.nixosModules.piavpn
  ];

  nixos.ifEnabled = {
    networking.networkmanager.enable = lib.mkForce true;
    networking.useDHCP = lib.mkForce false;

    services.piavpn.enable = true;
  };
}
