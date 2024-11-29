{
  config,
  options,
  pkgs,
  lib,
  mylib,
  ...
}:
with lib;
with mylib;
let
  enabled = config.sys.apps.cli.zsh;
in
{
  options.sys.apps.cli = with types; {
    zsh = mkBoolOpt false;
  };

  config = mkIf enabled {
    users.defaultUserShell = pkgs.zsh;
    sys.user.shell = pkgs.zsh;

    programs.zsh = {
      enable = true;
      enableCompletion = false;
    };
  };
}
