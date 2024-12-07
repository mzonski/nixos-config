{
  config,
  lib,
  mylib,
  ...
}:

with lib;
with mylib;
let
  enabled = config.programs.fastfetch.enable;
in
{
  config = mkIf enabled {
    programs.fastfetch = {
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
