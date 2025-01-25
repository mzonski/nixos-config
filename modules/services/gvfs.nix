# {
#   config,
#   lib,
#   pkgs,
#   ...
# }:
# let
#   enabled = config.services.gvfs.enable;
#   inherit (lib) mkIf;
# in
# {
#   config = mkIf enabled {
#     services.gvfs.package = pkgs.gvfs;
#   };
# }
{ }
