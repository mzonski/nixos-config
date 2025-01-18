{
  config,
  lib,
  pkgs,
  ...
}:
let
  enabled = config.programs.gnupg.agent.enable;
  inherit (lib) mkIf;

in
{
  config = mkIf enabled {
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
        enableSSHSupport = true;
        enableBrowserSocket = true;
      };

      dirmngr.enable = true;
    };
  };
}
