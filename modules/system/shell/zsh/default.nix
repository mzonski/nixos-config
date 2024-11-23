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
  cfg = config.sys.shell.zsh;
in
{
  options.sys.shell.zsh = with types; {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    users.defaultUserShell = pkgs.zsh;
    sys.user.shell = pkgs.zsh;

    programs.zsh = {
      enable = true;
      enableCompletion = false;
    };
  };
}
