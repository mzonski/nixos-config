{ delib, lib, ... }:

let
  inherit (delib) module;
in
module {
  name = "programs.desktop.file-manager-templates";

  home.always =
    { myconfig, ... }:
    let
      inherit (lib) mkIf;
      anyFileManagerEnabled =
        myconfig.programs.desktop.thunar.enable || myconfig.programs.desktop.pcmanfm.enable;
    in
    {

      home.file."Templates" = mkIf anyFileManagerEnabled {
        source = ./templates;
        recursive = true;
      };
    };
}
