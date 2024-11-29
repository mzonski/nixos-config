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
  enabled = config.hom.apps.cli.fastfetch;
in
{

  options.hom.apps.cli = {
    fastfetch = mkBoolOpt false;
  };

  config = mkIf enabled {
    programs.fastfetch = {
      enable = true;
      settings = {
        logo = {
          type = "auto";
        };
        display = {
          size.binaryPrefix = "si";
          color = "blue";
          separator = "   ";
        };
        modules = [
          "title"
          "separator"
          {
            type = "datetime";
            key = "TimeStamp";
            format = "{1}-{3}-{11} {14}:{17}:{20}";
          }
          "Host"
          "Chassis"
          "Bios"
          "Board"
          "OS"
          "Kernel"
          "Uptime"
          "LocalIp"
          "CPU"
          "GPU"
          "Memory"
          "Disk"
          "Break"
          "Colors"
        ];
      };
    };
  };
}
