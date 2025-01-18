{
  config,
  lib,
  lib',
  ...
}:

with lib;
with lib';
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
