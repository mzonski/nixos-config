{
  delib,
  host,
  lib,
  ...
}:
let
  inherit (delib)
    module
    moduleOptions
    boolOption
    strOption
    intOption
    submodule
    attrsOfOption
    noDefault
    enumOption
    allowNull
    ;
  inherit (lib)
    mkIf
    mkMerge
    imap0
    concatStringsSep
    ;
  inherit (lib.lists)
    elem
    all
    ;
  inherit (builtins)
    toString
    attrNames
    ;

  networkConfig = {
    lan = {
      vlanId = 0;
      octet = 0;
      prefixLength = 24;
    };
    home = {
      vlanId = 101;
      octet = 1;
      prefixLength = 24;
    };
    vpn = {
      vlanId = 102;
      octet = 2;
      prefixLength = 24;
    };
    iot = {
      vlanId = 103;
      octet = 3;
      prefixLength = 24;
    };
    guest = {
      vlanId = 104;
      octet = 4;
      prefixLength = 24;
    };
    public = {
      vlanId = 105;
      octet = 5;
      prefixLength = 24;
    };
  };

  validVlans = attrNames networkConfig;

in
module {
  name = "features.vnets";

  options = moduleOptions {
    enable = boolOption false;
    interface = noDefault (strOption null);
    vlans = attrsOfOption (submodule {
      options = {
        lastOctet = allowNull (intOption null);
        macAddress = noDefault (strOption null);
      };
    }) { };
    defaultOctet = allowNull (intOption null);
    defaultVlan = noDefault (enumOption (validVlans) null);
    disableBridgeFiltering = boolOption true;
  };

  nixos.ifEnabled =
    { cfg, ... }:
    {
      assertions = [
        {
          assertion = all (vlan: elem vlan validVlans) (attrNames cfg.vlans);
          message = "vlans keys must be one of: ${concatStringsSep ", " validVlans}";
        }
        {
          assertion =
            let
              hasVlansWithoutLastOctet = lib.any (vlanCfg: vlanCfg.lastOctet == null) (lib.attrValues cfg.vlans);
            in
            !hasVlansWithoutLastOctet || (cfg.defaultOctet != null);
          message = "defaultOctet must be set when any vlan is missing lastOctet";
        }
      ];

      networking = {
        hostName = host.name;
        networkmanager.enable = false;
        useNetworkd = true;
        useDHCP = false;
      };

      systemd.network =
        let
          allVlans = attrNames cfg.vlans;
          getVlanId = vlanName: networkConfig.${vlanName}.vlanId;
          getSubnetIp =
            vlanName: lastOctet: "10.0.${toString networkConfig.${vlanName}.octet}.${toString lastOctet}";
          getGatewayIp = vlanName: getSubnetIp vlanName 1;
          getCidrIp =
            vlanName: lastOctet:
            "${getSubnetIp vlanName lastOctet}/${toString networkConfig.${vlanName}.prefixLength}";
          getVlanInterfaceName = vlanName: "vlan${toString (getVlanId vlanName)}";
          getBridgeInterfaceName = vlanName: "br${toString (getVlanId vlanName)}";

          genAllVlanNames = vlans: map (vlanName: (getVlanInterfaceName vlanName)) vlans;
          isPrimaryVlan = vlanName: defaultVlan: vlanName == defaultVlan;
          getRequiredForOnline =
            vlanName: defaultVlan: if (isPrimaryVlan vlanName defaultVlan) then "yes" else "routable";

          generateNetDevVlan =
            vlanName:
            let
              vlanInterfaceName = getVlanInterfaceName vlanName;
              bridgeInterfaceName = getBridgeInterfaceName vlanName;
            in
            {
              "10-${vlanInterfaceName}" = {
                netdevConfig = {
                  Kind = "vlan";
                  Name = vlanInterfaceName;
                };
                vlanConfig.Id = getVlanId vlanName;
              };
              "15-${bridgeInterfaceName}" = {
                netdevConfig = {
                  Kind = "bridge";
                  Name = bridgeInterfaceName;
                };
              };
            };
          generateNetworkVlan =
            idx: vlanName:
            let
              vlanId = getVlanId vlanName;
              vlanInterfaceName = getVlanInterfaceName vlanName;
              bridgeInterfaceName = getBridgeInterfaceName vlanName;
              Gateway = getGatewayIp vlanName;
              vlanCfg = cfg.vlans.${vlanName};
            in
            {
              "35-${vlanInterfaceName}" = {
                matchConfig.Name = vlanInterfaceName;
                bridge = [ bridgeInterfaceName ];
                linkConfig.RequiredForOnline = getRequiredForOnline vlanName cfg.defaultVlan;
              };

              "40-${bridgeInterfaceName}" = {
                matchConfig.Name = bridgeInterfaceName;
                address = [
                  (getCidrIp vlanName (if vlanCfg.lastOctet != null then vlanCfg.lastOctet else cfg.defaultOctet))
                ];
                dns = [ Gateway ];
                routes = [
                  {
                    inherit Gateway;
                    Table = vlanId;
                  }
                  {
                    inherit Gateway;
                  }
                ];
                routingPolicyRules = [
                  {
                    Table = vlanId;
                    From = getCidrIp vlanName 0;
                    Priority = if (isPrimaryVlan vlanName cfg.defaultVlan) then 100 else 101 + idx;
                  }
                ];
                linkConfig = {
                  MACAddress = vlanCfg.macAddress;
                  RequiredForOnline = getRequiredForOnline vlanName cfg.defaultVlan;
                };
              };
            };
        in
        {
          enable = true;
          netdevs = mkMerge (map generateNetDevVlan allVlans);
          networks = lib.foldl' (a: b: a // b) { } (
            [
              {
                "30-${cfg.interface}" = {
                  matchConfig.Name = cfg.interface;
                  vlan = genAllVlanNames allVlans;
                  linkConfig.RequiredForOnline = "no";
                };
              }
            ]
            ++ (imap0 (idx: vlanName: generateNetworkVlan idx vlanName) allVlans)
          );
        };

      boot.kernel.sysctl = mkIf cfg.disableBridgeFiltering {
        "net.ipv4.conf.all.rp_filter" = 2;
        "net.ipv4.conf.default.rp_filter" = 2;
        "net.bridge.bridge-nf-call-iptables" = 0;
        "net.bridge.bridge-nf-call-ip6tables" = 0;
        "net.bridge.bridge-nf-call-arptables" = 0;
      };
    };
}
