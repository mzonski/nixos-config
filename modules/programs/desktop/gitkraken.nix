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
  name = "programs.development.gitkraken";

  options = singleEnableOption host.isDesktop;

  home.ifEnabled = {
    home.packages = (
      with pkgs;
      [
        gitkraken
      ]
    );

    # home.file = mkIf (cfg.theme == "catppuccin-mocha") {
    #   ".gitkraken/themes/catppuccin-mocha.jsonc".source = pkgs.fetchurl {
    #     url = "https://raw.githubusercontent.com/catppuccin/gitkraken/1ed3b2807f0ecbeb0a276fc17af26daf48874caf/themes/catppuccin-mocha.jsonc";
    #     sha256 = "sha256-u97bjJi3V2AI8Hw9wI25KfSe4bneX0QcOU0rzmeGaMM=";
    #   };
    # };
  };
}
