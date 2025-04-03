{ delib, pkgs, ... }:

let
  inherit (delib) module;
in
module {
  name = "programs.hyprland";

  home.ifEnabled = {
    home.packages = with pkgs; [
      libnotify
      unstable.grimblast
    ];
  };
}
