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
      "text/x-python" = [ launcher ];
      "text/json" = [ launcher ];
      "application/octet-stream" = [ launcher ];
      "application/x-desktop" = [ launcher ];
    };
}
