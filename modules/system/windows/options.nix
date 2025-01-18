{ lib', config, ... }:
let
  inherit (lib') mkStrOpt';
in
{
  options.windows = {
    variant = mkStrOpt' null "sets window manager"; # add gnome lol
  };

  config = {
    assertions = [
      {
        assertion = config.windows.variant != null;
        message = "windows.variant must be set to a valid window manager";
      }
    ];
  };
}
