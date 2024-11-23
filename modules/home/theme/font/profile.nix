{
  lib,
  config,
  pkgs,
  ...
}:
let
  mkFontOption = kind: {
    name = lib.mkOption {
      type = lib.types.str;
      description = "Family name for ${kind} font profile";
      example = "Fira Sans";
      default = "FiraCode Nerd Font";
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; };
      description = "Package for ${kind} font profile";
      example = "pkgs.fira-code";
    };
    size = lib.mkOption {
      type = lib.types.int;
      default = 14;
      description = "Size in pixels for ${kind} font profile";
      example = "14";
    };
  };
  cfg = config.hom.theme.fontProfiles;
in
{
  options.hom.theme.fontProfiles = {
    enable = lib.mkEnableOption "Whether to enable font profiles";
    monospace = mkFontOption "monospace";
    regular = mkFontOption "regular";
  };

  config = lib.mkIf cfg.enable {
    fonts.fontconfig.enable = true;
    home.packages = [
      cfg.monospace.package
      cfg.regular.package
    ];
  };
}
