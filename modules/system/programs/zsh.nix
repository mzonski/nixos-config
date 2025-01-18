{
  config,
  pkgs,
  lib,
  ...
}:
let
  enabled = config.programs.zsh.enable;
  inherit (lib) mkIf;
in
{
  config = mkIf enabled {
    users.defaultUserShell = pkgs.zsh;
    host.user.shell = pkgs.zsh;

    programs.zsh.enableCompletion = true;
  };
}
