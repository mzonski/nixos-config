{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    mkEnableOption
    mkIf
    ;
  mkFontOption = kind: {
    name = mkOption {
      type = types.str;
      description = "Family name for ${kind} font profile";
      example = "Fira Sans";
      default = "FiraCode Nerd Font";
    };
    package = mkOption {
      type = types.package;
      default = pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; };
      description = "Package for ${kind} font profile";
      example = "pkgs.fira-code";
    };
    size = mkOption {
      type = types.int;
      default = 14;
      description = "Size in pixels for ${kind} font profile";
      example = "14";
    };
  };
  cfg = config.hom.theme.fontProfiles;
in
{
  options.hom.theme.fontProfiles = {
    enable = mkEnableOption "Whether to enable font profiles";
    monospace = mkFontOption "monospace";
    regular = mkFontOption "regular";
  };

  config = mkIf cfg.enable {
    fonts.fontconfig.enable = true;
    home.packages = [
      cfg.monospace.package
      cfg.regular.package
    ];
  };
}
