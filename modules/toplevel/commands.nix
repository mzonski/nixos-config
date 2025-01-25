{ delib, ... }:
let
  inherit (delib) module strOption;
in
module {
  name = "commands";

  options.commands = {
    runTerminal = strOption "kitty";
    runFileManager = strOption "thunar";
    runClipboardHistory = strOption "nwg-clipman";
    runColorPicker = strOption "hyprpicker -a";
    runDrun = strOption "rofi -show drun -show-icons";
    captureWholeScreen = strOption "grimblast --freeze --notify --cursor copysave screen";
    captureArea = strOption "grimblast --freeze --notify --cursor copysave area";
  };
}
