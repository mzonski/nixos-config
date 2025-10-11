{ delib, host, ... }:
let
  inherit (delib) singleEnableOption module;
in
module {
  name = "programs.browser.xdg";

  options = singleEnableOption host.isDesktop;

  myconfig.ifEnabled.xdg.mime.recommended =
    let
      launcher = "firefox.desktop";
    in
    {
      "text/html" = [ launcher ];
      "text/xml" = [ launcher ];
      "x-scheme-handler/http" = [ launcher ];
      "x-scheme-handler/https" = [ launcher ];
      "application/pdf" = [ launcher ];
    };
}
