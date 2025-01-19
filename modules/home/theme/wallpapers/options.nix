{
  lib,
  lib',
  ...
}:

with lib;
with lib';
{
  options.hom.theme.wallpaper = mkOption {
    type = types.nullOr types.path;
    default = null;
    description = ''
      Wallpaper path
    '';
  };
}
