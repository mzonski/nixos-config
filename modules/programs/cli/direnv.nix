{
  config,
  lib,
  ...
}:

let
  enabled = config.programs.direnv.enable;

  inherit (lib) mkIf;
in
{
  config = mkIf enabled {
    programs.direnv = {
      nix-direnv.enable = true;
    };
  };
}
