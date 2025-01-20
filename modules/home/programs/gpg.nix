{
  pkgs,
  config,
  lib,
  ...
}:
let
  enabled = config.programs.gpg.enable;
  inherit (config.hom) pgpKey;

  inherit (lib) mkIf mkOption types;
in
{
  options.hom.pgpKey = mkOption {
    type = types.path;
    description = "Path to public pgp key";
  };

  config = mkIf ((pgpKey != null) && enabled) {
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableExtraSocket = true;
      pinentryPackage = pkgs.wayprompt;
    };

    programs.gpg = {
      settings = {
        trust-model = "tofu+pgp";
      };
      publicKeys = [
        {
          source = pgpKey;
          trust = 5;
        }
      ];
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

    home.packages = with pkgs; [
      kleopatra
    ];
  };
}
