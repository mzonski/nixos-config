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
  cfg = config.hom.apps.cryptography;
in
{
  options.hom.apps.cryptography = {
    certificate-manager = mkBoolOpt false;
  };

  config = mkIf cfg.certificate-manager {
    home.packages = with pkgs; [
      openssl # For certificate operations
      paperkey # Backup tool for keys
      kleopatra # Certificate manager and GUI for OpenPGP and CMS cryptography
    ];
  };
}
