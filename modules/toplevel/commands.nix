{ lib', ... }:
let
  inherit (lib') mkStrOpt;
in
{
  options.commands = {
    runTerminal = mkStrOpt "kitty";
    runFileManager = mkStrOpt "thunar";
    runClipboardHistory = mkStrOpt "nwg-clipman";
    runColorPicker = mkStrOpt "hyprpicker -a";
    runDrun = mkStrOpt "rofi -show drun -show-icons";
    captureWholeScreen = mkStrOpt "grimblast --freeze --notify --cursor copysave screen";
    captureArea = mkStrOpt "grimblast --freeze --notify --cursor copysave area";
  };
}
