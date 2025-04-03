{ delib, homeconfig, ... }:

let
  inherit (delib) module;
in
module {
  name = "programs.wayland";

  home.ifEnabled = {
    home.file = {
      "${homeconfig.home.homeDirectory}/waybar/scripts" = {
        source = ./scripts;
        recursive = true;
        executable = true;
      };
    };
  };
}
