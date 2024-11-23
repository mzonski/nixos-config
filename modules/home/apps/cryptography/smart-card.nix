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
    smart-card = mkBoolOpt false;
  };

  config = mkIf cfg.smart-card {
    home.packages = with pkgs; [
      opensc # Smart card utilities and libraries
      pcsctools # PC/SC tools for smart card operations
      ccid # Smart card driver
    ];
  };
}
