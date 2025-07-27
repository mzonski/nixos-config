{
  delib,
  lib,
  config,
  ...
}:
let
  inherit (delib) module;
  inherit (lib) mkDefault;
in
module {
  name = "features.virt-manager.bridge";

  nixos.ifEnabled =
    { cfg, ... }:
    {
      assertions = [
        {
          assertion = !config.networking.networkmanager.enable;
          message = "features.virt-manager.bridge cannot be used with NetworkManager enabled.";
        }
      ];

      networking = {
        useNetworkd = mkDefault true;
        useDHCP = mkDefault true;

        networkmanager.unmanaged = [
          cfg.bridgeInterface
          cfg.externalInterface
        ];

        nat = {
          enable = true;
          enableIPv6 = false;
          externalInterface = cfg.externalInterface;
          internalInterfaces = [ cfg.virtualBridgeInterface ];
          internalIPs = [ cfg.virtualBridgeNetwork ];
        };

        interfaces = {
          "${cfg.externalInterface}".useDHCP = mkDefault false;
          "${cfg.bridgeInterface}" = {
            useDHCP = mkDefault true;
            macAddress = mkDefault cfg.macAddress;
          };
        };
      };

      systemd.network = {
        enable = true;
        netdevs = {
          "${cfg.bridgeInterface}" = {
            netdevConfig = {
              Name = cfg.bridgeInterface;
              Kind = "bridge";
            };
          };
        };

        networks = {
          "30-${cfg.externalInterface}" = {
            matchConfig.Name = cfg.externalInterface;
            networkConfig = {
              Bridge = cfg.bridgeInterface;
            };
          };

          "40-${cfg.bridgeInterface}" = {
            matchConfig.Name = cfg.bridgeInterface;
            networkConfig = {
              DHCP = "yes";
            };
          };
        };
      };
    };
}
