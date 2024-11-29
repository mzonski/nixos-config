{
  config,
  options,
  lib,
  pkgs,
  mylib,
  ...
}:

with lib;
with mylib;
{
  options.hom.theme.wallpaper = mkOption {
    type = types.nullOr types.path;
    default = null;
    description = ''
      Wallpaper path
    '';
  };
}
