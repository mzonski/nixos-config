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
          format = "{1}-{3}-{11} {14}:{17}:{20}";
        }
        "Uptime"
        "separator"
        "Kernel"
        "OS"
        {
          type = "command";
          key = "NixOS Gen";
          text = "nix-env --list-generations | tail -n1 | awk '{print $1}'";
        }
        {
          type = "command";
          key = "Home Gen";
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
