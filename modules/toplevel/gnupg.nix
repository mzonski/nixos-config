{
  lib,
  delib,
  pkgs,
  host,
  ...
}:

let
  inherit (delib) module;
  inherit (lib) mkIf;
in
module {
  name = "toplevel.gnupg";

  nixos.always = {
    environment.shellInit = ''
      export GPG_TTY="$(tty)"
      export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
      gpgconf --launch gpg-agent
    '';

    environment.systemPackages = mkIf host.isDesktop (
      with pkgs;
      [
        kdePackages.kleopatra
      ]
    );

    programs.gnupg = {
      agent = {
        enable = true;
        enableSSHSupport = true;
        enableBrowserSocket = true;
      };

      dirmngr.enable = true;
    };

    services.pcscd.enable = if host.isDesktop then true else false;
  };

  home.always =
    { myconfig, ... }:
    let
      inherit (builtins) attrValues mapAttrs;
      publicKeys = attrValues (
        mapAttrs (username: key: {
          source = key;
          trust = 5;
        }) myconfig.keys.gpg
      );
    in
    {
      services.gpg-agent = {
        enable = true;
        enableSshSupport = true;
        enableExtraSocket = true;
      };

      programs.gpg = {
        enable = true;
        settings = {
          trust-model = "tofu+pgp";
        };
        inherit publicKeys;
        scdaemonSettings = {
          disable-ccid = true;
        };
      };

      systemd.user.services = {
        link-gnupg-sockets = {
          Unit = {
            Description = "link gnupg sockets from /run to /home";
          };
          Service = {
            Type = "oneshot";
            ExecStart = "${pkgs.coreutils}/bin/ln -Tfs /run/user/%U/gnupg %h/.gnupg-sockets";
            ExecStop = "${pkgs.coreutils}/bin/rm $HOME/.gnupg-sockets";
            RemainAfterExit = true;
          };
          Install.WantedBy = [ "default.target" ];
        };
      };

      home.packages = mkIf host.isDesktop (
        with pkgs;
        [
          kdePackages.kleopatra
        ]
      );
    };
}
