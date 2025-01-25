{ delib, ... }:
delib.rice {
  name = "catppuccin-sharp-dark";

}
# {
#   config,
#   lib,
#   lib',
#   ...
# }:

# let
#   cfg = config.hom.theme.catpuccin;

#   inherit (lib') mkBoolOpt;
#   inherit (lib) mkIf;
# in
# {
#   options.hom.theme.catpuccin = {
#     enable = mkBoolOpt true;
#   };

#   config = mkIf cfg.enable {
#     catppuccin = {
#       enable = false;
#       flavor = "mocha";
#       cursors.enable = false;
#       cursors.flavor = "mocha";

#       kvantum.enable = false;
#       kvantum.apply = false;

#       kitty.enable = true;
#       zsh-syntax-highlighting.enable = true;

#       gtk = {
#         enable = false;
#         gnomeShellTheme = false;

#         icon.enable = false;

#         tweaks = [ "normal" ];
#       };
#     };
#   };
# }
