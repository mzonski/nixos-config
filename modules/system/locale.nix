{ lib, ... }:
let
  inherit (lib) mkDefault;
in
{
  i18n = {
    defaultLocale = mkDefault "en_GB.UTF-8";
    extraLocaleSettings = {
      LANG = mkDefault "en_GB.UTF-8";
      LANGUAGE = mkDefault "en_GB.UTF-8";
      LC_ADDRESS = mkDefault "pl_PL.UTF-8";
      LC_COLLATE = mkDefault "pl_PL.UTF-8";
      LC_CTYPE = mkDefault "en_GB.UTF-8";
      LC_IDENTIFICATION = mkDefault "pl_PL.UTF-8";
      LC_MEASUREMENT = mkDefault "pl_PL.UTF-8";
      LC_MESSAGES = mkDefault "pl_PL.UTF-8";
      LC_MONETARY = mkDefault "pl_PL.UTF-8";
      LC_NAME = mkDefault "pl_PL.UTF-8";
      LC_NUMERIC = mkDefault "pl_PL.UTF-8";
      LC_PAPER = mkDefault "pl_PL.UTF-8";
      LC_TELEPHONE = mkDefault "pl_PL.UTF-8";
      LC_TIME = mkDefault "en_GB.UTF-8";
    };
    supportedLocales = mkDefault [
      "pl_PL.UTF-8/UTF-8"
      "en_GB.UTF-8/UTF-8"
    ];
  };

  location.provider = mkDefault "geoclue2";
  time.timeZone = mkDefault "Europe/Warsaw";
  time.hardwareClockInLocalTime = mkDefault true;

  console.keyMap = mkDefault "pl";

  networking.timeServers = mkDefault [
    "tempus1.gum.gov.pl"
    "tempus2.gum.gov.pl"
  ];
}
