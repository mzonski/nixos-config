{
  _config,
  _lib,
  _pkgs,
  _modulesPath,
  ...
}:

{
  # Time and Locale Configuration
  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pl_PL.UTF-8";
    LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT = "pl_PL.UTF-8";
    LC_MONETARY = "pl_PL.UTF-8";
    LC_NAME = "pl_PL.UTF-8";
    LC_NUMERIC = "pl_PL.UTF-8";
    LC_PAPER = "pl_PL.UTF-8";
    LC_TELEPHONE = "pl_PL.UTF-8";
    LC_TIME = "pl_PL.UTF-8";
  };

  # Input Configuration
  services.xserver.xkb = {
    layout = "pl";
    variant = "";
  };
  console.keyMap = "pl2"; # Console keymap
}
