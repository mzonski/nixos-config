{
  delib,
  host,
  lib,
  config,
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
    substring
    hashString
    ;

  networkConfig = {
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
  name = "homelab.networking";

  options = moduleOptions {
    enable = boolOption false;
    physicalInterfaceName = strOption "phys0";
    vlans = attrsOfOption (submodule {
      options = {
        lastOctet = allowNull (intOption null);
        macAddress = noDefault (strOption null);
      };
    }) { };
    defaultOctet = allowNull (intOption null);
    defaultVlan = noDefault (enumOption (validVlans) null);
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
        hostId = (substring 0 8 (hashString "md5" host.name));
        networkmanager.enable = false;
        useNetworkd = lib.mkForce true;
        useDHCP = false;
      };

      sops =
        let
          macAddressSopsSecret = "${cfg.physicalInterfaceName}_mac_address";
        in
        {
          secrets.${macAddressSopsSecret} = {
            sopsFile = host.secretsFile;
            owner = "root";
            group = "root";
          };
          templates."network_${cfg.physicalInterfaceName}_link" = {
            content = ''
              [Match]
              PermanentMACAddress=${config.sops.placeholder.${macAddressSopsSecret}}

              [Link]
              Name=${cfg.physicalInterfaceName}
            '';
            owner = "root";
            group = "root";
            path = "/etc/systemd/network/10-${cfg.physicalInterfaceName}.link";
          };
        };

      systemd.tmpfiles.rules = [
        "z ${config.sops.templates."network_${cfg.physicalInterfaceName}_link".path} 0755 root root - -"
      ];

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
          getVlanInterfaceName = vlanName: "vlan-${vlanName}";
          getBridgeInterfaceName = vlanName: "br-${vlanName}";

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
              "15-${vlanInterfaceName}" = {
                netdevConfig = {
                  Kind = "vlan";
                  Name = vlanInterfaceName;
                };
                vlanConfig.Id = getVlanId vlanName;
              };
              "16-${bridgeInterfaceName}" = {
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

              "40-${bridgeInterfaceName}" =
                let
                  subnetCidrIp = getCidrIp vlanName 0;
                  lastOctet = if vlanCfg.lastOctet != null then vlanCfg.lastOctet else cfg.defaultOctet;
                  ipAddress = getSubnetIp vlanName lastOctet;
                in
                {
                  matchConfig.Name = bridgeInterfaceName;
                  address = [
                    (getCidrIp vlanName lastOctet)
                  ];
                  dns = [ Gateway ];
                  routes = [
                    {
                      Destination = subnetCidrIp;
                      Scope = "link";
                      Table = vlanId;
                    }
                    {
                      inherit Gateway;
                      Table = vlanId;
                    }
                    {
                      inherit Gateway;
                      Metric = 100;
                    }
                  ];
                  routingPolicyRules = [
                    {
                      Table = vlanId;
                      To = ipAddress;
                      Priority = if (isPrimaryVlan vlanName cfg.defaultVlan) then 100 else 200 + idx;
                    }
                    {
                      Table = vlanId;
                      From = ipAddress;
                      Priority = if (isPrimaryVlan vlanName cfg.defaultVlan) then 101 else 201 + idx;
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
                "20-${cfg.physicalInterfaceName}" = {
                  matchConfig.Name = cfg.physicalInterfaceName;
                  vlan = genAllVlanNames allVlans;
                  linkConfig.RequiredForOnline = "no";
                };
              }
            ]
            ++ (imap0 (idx: vlanName: generateNetworkVlan idx vlanName) allVlans)
          );
        };
    };
}
