{ delib, ... }:

let
  inherit (delib) module singleEnableOption;
in
module {
  name = "programs.cli.fastfetch";

  options = singleEnableOption true;

  home.ifEnabled.programs.fastfetch = {
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
        {
          type = "datetime";
          key = "Timestamp";
          format = "{year}-{month-pretty}-{day-pretty} {hour-pretty}:{minute-pretty}:{second-pretty}";
        }
        "Uptime"
        "separator"
        "Kernel"
        "OS"
        {
          type = "command";
          key = "NixOS Generation";
          text = "readlink /nix/var/nix/profiles/system | cut -d- -f2";
        }
        {
          type = "command";
          key = "Home Generation";
          text = "home-manager generations | head -n1 | awk '{print $5}'";
        }
        "Break"
        "Board"
        "CPU"
        "GPU"
        "Memory"
        "Disk"
        "Break"
        "Colors"
      ];
    };
  };
}
