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
  name = "programs.desktop.display-manager.gdm";

  options = singleEnableOption false;

  nixos.ifEnabled = {
    services.xserver.displayManager.gdm = {
      enable = true;
      wayland = true;
      autoSuspend = false;
      debug = false;

      settings = { };
      banner = ''
        Siema!
        Hello!
      '';
      autoLogin.delay = 3;
    };
  };
}
