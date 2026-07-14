{ delib, pkgs, ... }:

let
  inherit (delib) module singleEnableOption;
in
module {
  name = "programs.sddm";

  options = singleEnableOption false;

  nixos.ifEnabled = {
    users.users.sddm.autoSubUidGidRange = true;

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      autoNumlock = true;
    };
  };
}
