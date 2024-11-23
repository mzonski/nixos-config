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
  cfg = config.sys.locale.timezone;
in
{
  options.sys.locale.timezone = with types; {
    warsaw = mkBoolOpt false;
  };

  config = mkIf cfg.warsaw {
    location.provider = lib.mkDefault "geoclue2";
    time.timeZone = lib.mkDefault "Europe/Warsaw";
    time.hardwareClockInLocalTime = true;
  };
}
