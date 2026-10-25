{
  delib,
  lib,
  pkgs,
  ...
}:
let
  inherit (delib) module singleEnableOption;
  inherit (lib) concatStringsSep;
in
module {
  name = "services.tailscale-server";

  options = singleEnableOption false;

  nixos.ifEnabled =
    { myconfig, cfg, ... }:
    {
      networking.firewall.trustedInterfaces = [ "tailscale0" ];

      services.tailscale = {
        enable = true;
        useRoutingFeatures = "server";
        openFirewall = true;
        extraUpFlags = [
          "--advertise-exit-node"
          "--advertise-routes=${
            concatStringsSep "," ([ "10.0.0.0/24" ] ++ myconfig.homelab.networking.availableCidrIpSubnets)
          }"
        ];
      };
      environment.systemPackages = with pkgs; [ ethtool ];

      networking.localCommands = ''
        ip rule add to 100.64.0.0/10 lookup 52 priority 50
      '';

      services.networkd-dispatcher = {
        enable = true;
        rules."50-tailscale-optimizations" = {
          onState = [ "routable" ];
          script = ''
            ${pkgs.ethtool}/bin/ethtool -K br-home rx-udp-gro-forwarding on rx-gro-list off
          '';
        };
      };
    };
}
