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
let
  cfg = config.sys.services.virtual-filesystem;
in
{
  options.sys.services.virtual-filesystem = with types; {
    gvfs = mkBoolOpt false;
  };

  config = mkIf cfg.gvfs {
    services.gvfs.enable = true;
    services.gvfs.package = pkgs.gvfs;
  };
}
