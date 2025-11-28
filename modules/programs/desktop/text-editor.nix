{ delib, host, ... }:
let
  inherit (delib) singleEnableOption module;
in
module {
  name = "programs.desktop.textEditor";

  options = singleEnableOption host.isDesktop;

  myconfig.ifEnabled.xdg.mime.recommended =
    let
      launcher = "org.gnome.TextEditor.desktop";
    in
    {
      "text/plain" = [ launcher ];
      "text/markdown" = [ launcher ];
      "text/json" = [ launcher ];
      "application/json" = [ launcher ];
      "text/yaml" = [ launcher ];
      "text/javascript" = [ launcher ];
      "text/x-c++src" = [ launcher ];
      "text/x-chdr" = [ launcher ];
      "text/x-rpm-spec" = [ launcher ];
      "text/x-python" = [ launcher ];
      "text/x-makefile" = [ launcher ];
      "application/x-tiled-tsx" = [ launcher ]; # typescript .tsx
      "text/vnd.trolltech.linguist" = [ launcher ]; # typescript .ts
      "application/x-desktop" = [ launcher ];
      "application/octet-stream" = [ launcher ];
    };
}
