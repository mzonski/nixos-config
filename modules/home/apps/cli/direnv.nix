{
  config,
  lib,
  mylib,
  ...
}:

with lib;
with mylib;
let
  enabled = config.programs.direnv.enable;
in
{
  config = mkIf enabled {
    programs.direnv = {
      nix-direnv.enable = true;
    };
  };
}
