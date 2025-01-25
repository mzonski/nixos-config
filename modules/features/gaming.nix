# {
#   config,
#   lib,
#   lib',
#   pkgs,
#   ...
# }:

# let
#   inherit (lib) mkIf;
#   inherit (lib') mkBoolOpt;
#   enabled = config.features.gaming.enable;
# in
# {
#   options.features.gaming = {
#     enable = mkBoolOpt false;
#     package = pkgs.steam.override {
#       extraPkgs =
#         pkgs: with pkgs; [
#           pango
#           libthai
#           harfbuzz
#         ];
#     };
#   };

#   config = mkIf enabled {
#     programs.steam.enable = true;
#     programs.gamemode.enable = true;

#     environment.sessionVariables = {
#       STEAM_FORCE_DESKTOPUI_SCALING = "1.6";
#     };

#     environment.systemPackages = with pkgs; [
#       # Steam
#       mangohud
#       gamemode
#       # WINE
#       wine
#       winetricks
#       protontricks
#       vulkan-tools
#       protonup-qt
#       # Extra dependencies
#       # https://github.com/lutris/docs/
#       gnutls
#       openldap
#       libgpg-error
#       freetype
#       sqlite
#       libxml2
#       xml2
#       SDL2
#     ];
#   };
# }
{ }
