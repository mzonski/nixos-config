{
  config,
  lib,
  pkgs,
  mylib,
  ...
}:

with lib;
with mylib;
let
  enabled = config.programs.chrome.enable;
in
{
  options.programs.chrome = {
    enable = mkBoolOpt false;
  };

  config = mkIf enabled {
    home.packages = with pkgs; [
      (google-chrome.override {
        commandLineArgs = [
          "--enable-features=MiddleClickAutoscroll"
        ];
      })
    ];
  };
}
