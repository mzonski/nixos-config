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
  cfg = config.sys.services.quietboot;
in
{
  options.sys.services.quietboot = with types; {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {

    console = {
      useXkbConfig = true;
      earlySetup = false;
    };

    boot = {
      plymouth = {
        enable = true;
        theme = "spinner-monochrome";
        themePackages = [
          (pkgs.plymouth-spinner-monochrome.override { inherit (config.boot.plymouth) logo; })
        ];
      };
      loader.timeout = 0;
      kernelParams = [
        "quiet"
        "loglevel=3"
        "systemd.show_status=auto"
        "udev.log_level=3"
        "rd.udev.log_level=3"
        "vt.global_cursor_default=0"
      ];
      consoleLogLevel = 0;
      initrd.verbose = false;
    };

  };
}
