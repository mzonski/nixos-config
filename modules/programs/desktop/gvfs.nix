{
  delib,
  pkgs,
  host,
  ...
}:

let
  inherit (delib) module singleEnableOption;
in
module {
  name = "services.gvfs";

  options = singleEnableOption host.isDesktop;

  nixos.ifEnabled.services.gvfs = {
    enable = true;
    package = pkgs.gvfs;
  };
}
