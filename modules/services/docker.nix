# { config, lib, ... }:

# let
#   enabled = config.virtualisation.docker.enable;
#   inherit (config.host) admin;
#   inherit (lib) mkIf;
# in
# {
#   config = mkIf enabled {
#     host.user.extraGroups = [ "docker" ];

#     virtualisation.docker = {
#       storageDriver = "btrfs"; # TODO: condition?
#       rootless = {
#         enable = true;
#         setSocketVariable = true;
#       };

#       daemon.settings = {
#         data-root = "/home/${admin}/Docker/";
#         userland-proxy = false;
#         experimental = true;
#         ipv6 = true;
#         fixed-cidr-v6 = "fd00::/80";
#         metrics-addr = "0.0.0.0:9323";
#         log-driver = "json-file";
#         log-opts.max-size = "10m";
#         log-opts.max-file = "10";
#       };
#     };
#   };
# }
{ }
