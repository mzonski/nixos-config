{
  config,
  options,
  lib,
  mylib,
  ...
}:
with lib;
with mylib;
let
  cfg = config.sys.locale.ponglish;
in
{
  options.sys.locale.ponglish = with types; {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    i18n = {
      defaultLocale = lib.mkDefault "en_GB.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = lib.mkDefault "pl_PL.UTF-8";
        LC_IDENTIFICATION = lib.mkDefault "pl_PL.UTF-8";
        LC_MEASUREMENT = lib.mkDefault "pl_PL.UTF-8";
        LC_MONETARY = lib.mkDefault "pl_PL.UTF-8";
        LC_NAME = lib.mkDefault "pl_PL.UTF-8";
        LC_NUMERIC = lib.mkDefault "pl_PL.UTF-8";
        LC_PAPER = lib.mkDefault "pl_PL.UTF-8";
        LC_TELEPHONE = lib.mkDefault "pl_PL.UTF-8";
        LC_TIME = lib.mkDefault "pl_PL.UTF-8";
      };
      supportedLocales = lib.mkDefault [
        "pl_PL.UTF-8/UTF-8"
        "en_GB.UTF-8/UTF-8"
      ];
    };
  };
}
