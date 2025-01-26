{
  delib,
  pkgs,
  host,
  ...
}:
let
  inherit (delib) module singleEnableOption;
in
module {
  name = "programs.desktop.geany";

  options = singleEnableOption host.isDesktop;

  home.ifEnabled = {
    home.packages = (
      with pkgs;
      [
        geany # text editor
      ]
    );

    # TODO: RICE
    # home.file = mkIf (cfg.colorScheme == "catppuccin-mocha") {
    #   ".config/geany/colorschemes/catppuccin-mocha.conf".source = pkgs.fetchurl {
    #     url = "https://raw.githubusercontent.com/catppuccin/geany/970c3408c84e63f052ee961166b6a3df51f865e7/src/catppuccin-mocha.conf";
    #     sha256 = "sha256-nQb9m6CHiy5ZXP4jmjWwNF4xEPqCc6dNC2rNDg1ut8Q=";
    #   };
    # };
  };
}
