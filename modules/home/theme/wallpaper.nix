{ lib, ... }:

let
  inherit (lib) mkOption types;
in
{
  options.hom.theme.wallpaper = mkOption {
    type = types.nullOr types.path;
    default = null;
    description = ''
      Wallpaper path
    '';
  };
}
