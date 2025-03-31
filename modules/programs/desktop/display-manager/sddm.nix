{ delib, pkgs, ... }:

let
  inherit (delib) module singleEnableOption;
in
module {
  name = "programs.sddm";

  options = singleEnableOption false;

  nixos.ifEnabled = {
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      autoNumlock = true;

      # theme = "";
      # settings = { };
      # wayland.compositor = "weston";

      # package = pkgs.kdePackages.sddm;
      # extraPackages = [ ];
    };
  };
}
