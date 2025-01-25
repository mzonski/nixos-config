# {
#   config,
#   lib,
#   pkgs,
#   lib',
#   ...
# }:

# let
#   enabled = config.programs.file-manager.app == "pcmanfm";
#   inherit (lib') mkBoolOpt;
#   inherit (lib) mkIf;
# in
# {
#   options.programs.file-manager = {
#     pcmanfm = mkBoolOpt false;
#   };

#   config = mkIf enabled {
#     home.packages = with pkgs; [
#       lxqt.pcmanfm-qt
#       xarchiver
#     ];
#   };
# }
{ }
