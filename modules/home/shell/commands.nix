{
  lib,
  pkgs,
  mylib,
  ...
}:

with lib;
with mylib;
{
  options.commands = {
    runTerminal = mkStrOpt "kitty";
    runFileManager = mkStrOpt "thunar";
    runClipboardHistory = mkStrOpt "nwg-clipman";
    runColorPicker = mkStrOpt "hyprpicker -a";
    runDrun = mkStrOpt "rofi -show drun -show-icons";
  };
}
