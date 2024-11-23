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
    yubikey = mkBoolOpt false;
  };

  config = mkIf cfg.yubikey {
    home.packages = with pkgs; [
      yubikey-manager # Main CLI tool for YubiKey management (ykman)
      yubico-piv-tool # Specific tool for PIV operations
    ];
  };
}
