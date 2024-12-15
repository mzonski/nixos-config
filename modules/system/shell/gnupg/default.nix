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
  cfg = config.sys.shell.gnupg;
in
{
  options.sys.shell.gnupg = with types; {
    enable = mkBoolOpt false;
    cacheTTL = mkOpt int 3600;
  };

  config = mkIf cfg.enable {
    # environment.shellInit = ''
    #   export GPG_TTY="$(tty)"
    #   export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    #   gpgconf --launch gpg-agent
    # '';

    environment.systemPackages = with pkgs; [
      kleopatra
    ];
    programs.gnupg = {
      agent = {
        enable = true;
        enableSSHSupport = true;
        enableBrowserSocket = true;
      };

      dirmngr.enable = true;
    };

  };
}
