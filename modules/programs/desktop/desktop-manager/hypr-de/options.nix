{ delib, host, ... }:

let
  inherit (delib)
    module
    boolOption
    intOption
    noDefault
    strOption
    enumOption
    ;
in
module {
  name = "programs.hyprland";

  options.programs.hyprland = {
    enable = boolOption false;
    idle = {
      lockEnabled = boolOption false;
      lockTimeout = intOption 660;
      turnOffDisplayTimeout = intOption 600;
      suspendTimeout = intOption 1800;
    };
    source = noDefault (enumOption [ "stable" "unstable" "input" ] null);
    monitors = {
      primary = {
        output = strOption "HDMI-A-1";
        workspaces = [
          1
          2
          3
          4
        ];
      };
      secondary = {
        output = strOption "DP-2";
        workspaces = [
          5
          6
          7
          8
        ];
      };
    };
  };
}
