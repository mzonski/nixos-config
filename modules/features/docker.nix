{ delib, ... }:

let
  inherit (delib) module singleEnableOption;
in
module {
  name = "features.docker";

  options = singleEnableOption false;

  myconfig.ifEnabled.user.groups = [ "docker" ];

  nixos.ifEnabled =
    { myconfig, ... }:
    let
      inherit (myconfig.admin) username;
    in
    {
      virtualisation.docker = {
        storageDriver = "btrfs"; # TODO: condition?
        rootless = {
          enable = true;
          setSocketVariable = true;
        };

        daemon.settings = {
          data-root = "/home/${username}/Docker/"; # TODO: persist
          userland-proxy = false;
          experimental = true;
          ipv6 = true;
          fixed-cidr-v6 = "fd00::/80";
          metrics-addr = "0.0.0.0:9323";
          log-driver = "json-file";
          log-opts.max-size = "10m";
          log-opts.max-file = "10";
        };
      };
    };
}
