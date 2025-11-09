{ delib, lib, ... }:
let
  inherit (delib)
    module
    moduleOptions
    boolOption
    strOption
    intOption
    listOfOption
    submodule
    allowNull
    enum
    attrsOfOption
    noDefault
    enumOption
    ;
  inherit (lib)
    mkIf
    mkMerge
    ;
  inherit (lib.lists)
    elem
    all
    unique
    filter
    ;
  inherit (lib.attrsets)
    mapAttrs
    mapAttrs'
    nameValuePair
    attrNames
    listToAttrs
    ;
  inherit (builtins)
    match
    elemAt
    head
    length
    ;
in
module {
  name = "features.vnets";

  options = moduleOptions {
    enable = boolOption false;
    interface = {
      name = strOption "";
      dhcp = boolOption true;
      staticIp = allowNull (strOption null);
      prefixLength = intOption 24;
    };
    vlans = listOfOption (enum [
      "lan"
      "home"
      "vpn"
      "iot"
      "guest"
      "public"
    ]) [ ];
    overrides = attrsOfOption (submodule {
      options = {
        dhcp = boolOption true;
        staticIp = allowNull (strOption null);
        prefixLength = intOption 24;
        macAddress = allowNull (strOption null);
      };
    }) { };
    defaultVlan = noDefault (
      enumOption [
        "lan"
        "home"
        "vpn"
        "iot"
        "guest"
        "public"
      ] null
    );
    disableBridgeFiltering = boolOption true;
  };

  nixos.ifEnabled =
    { cfg, ... }:
    let
      vlanConfig = {
        lan = {
          id = 0;
          subnet = "10.0.0";
        };
        home = {
          id = 101;
          subnet = "10.0.1";
        };
        vpn = {
          id = 102;
          subnet = "10.0.2";
        };
        iot = {
          id = 103;
          subnet = "10.0.3";
        };
        guest = {
          id = 104;
          subnet = "10.0.4";
        };
        public = {
          id = 105;
          subnet = "10.0.5";
        };
      };

      getVlanId = vlanName: vlanConfig.${vlanName}.id;
      getSubnet = vlanName: vlanConfig.${vlanName}.subnet;
      getGatewayIp = vlanName: "${getSubnet vlanName}.1";

      isValidMac =
        mac:
        let
          result = match "([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}" mac;
        in
        result != null;

      defaultBridgeConfigs = listToAttrs (
        map (
          vlanName:
          nameValuePair vlanName {
            dhcp = true;
            macAddress = null;
            staticIp = null;
            prefixLength = 24;
          }
        ) cfg.vlans
      );

      allBridgeConfigs = defaultBridgeConfigs // cfg.overrides;

      taggedVlanNames = filter (vlanName: getVlanId vlanName != 0) (attrNames allBridgeConfigs);

      vlanInterfaceConfigs = listToAttrs (
        map (
          vlanName:
          nameValuePair "vlan-${vlanName}" {
            id = getVlanId vlanName;
            interface = cfg.interface.name;
          }
        ) taggedVlanNames
      );

      bridgeToInterfaceMapping = mapAttrs (
        vlanName: bridgeCfg:
        let
          vlanId = getVlanId vlanName;
        in
        {
          interfaces = if vlanId == 0 then [ cfg.interface.name ] else [ "vlan-${vlanName}" ];
        }
      ) allBridgeConfigs;

      bridgeIpConfigs = mapAttrs (
        vlanName: bridgeCfg:
        mkMerge [
          (
            if bridgeCfg.dhcp then
              { useDHCP = true; }
            else if bridgeCfg.staticIp != null then
              {
                useDHCP = false;
                ipv4.addresses = [
                  {
                    address = bridgeCfg.staticIp;
                    prefixLength = bridgeCfg.prefixLength;
                  }
                ];
              }
            else
              { useDHCP = true; }
          )

          (mkIf (bridgeCfg.macAddress != null) {
            macAddress = bridgeCfg.macAddress;
          })
        ]
      ) allBridgeConfigs;

      allNetworkInterfaceConfigs = mkMerge [
        {
          ${cfg.interface.name} =
            if cfg.interface.dhcp then
              { useDHCP = true; }
            else if cfg.interface.staticIp != null then
              {
                useDHCP = false;
                ipv4.addresses = [
                  {
                    address = cfg.interface.staticIp;
                    prefixLength = cfg.interface.prefixLength;
                  }
                ];
              }
            else
              { useDHCP = false; };
        }
        (mapAttrs' (vlanName: ipCfg: nameValuePair "br-${vlanName}" ipCfg) bridgeIpConfigs)
      ];

      primaryBridgeName =
        if allBridgeConfigs ? lan then
          "br-lan"
        else if attrNames allBridgeConfigs != [ ] then
          "br-${head (attrNames allBridgeConfigs)}"
        else
          null;

    in
    {
      assertions = [
        {
          assertion = cfg.vlans != [ ];
          message = "At least one VLAN must be configured in the vlans list";
        }
        {
          assertion = all (vlanName: elem vlanName cfg.vlans) (attrNames cfg.overrides);
          message = "All overrides keys must match configured VLAN names";
        }
        {
          assertion = all (
            vlanName:
            let
              bridgeCfg = allBridgeConfigs.${vlanName};
            in
            bridgeCfg.dhcp || bridgeCfg.staticIp != null
          ) (attrNames allBridgeConfigs);
          message = "Each bridge must have either dhcp = true or a staticIp defined";
        }
        {
          assertion = all (
            vlanName:
            let
              bridgeCfg = allBridgeConfigs.${vlanName};
            in
            if bridgeCfg.staticIp != null then
              let
                expectedSubnet = getSubnet vlanName;
                ipParts = match "([0-9]+)\\.([0-9]+)\\.([0-9]+)\\.([0-9]+)" bridgeCfg.staticIp;
                actualSubnet =
                  if ipParts != null then "${elemAt ipParts 0}.${elemAt ipParts 1}.${elemAt ipParts 2}" else "";
              in
              actualSubnet == expectedSubnet
            else
              true
          ) (attrNames allBridgeConfigs);
          message = "Static IP addresses must match their VLAN's subnet (e.g., home VLAN must use 10.0.1.x)";
        }
        {
          assertion = all (
            vlanName:
            let
              bridgeCfg = allBridgeConfigs.${vlanName};
            in
            if bridgeCfg.macAddress != null then isValidMac bridgeCfg.macAddress else true
          ) (attrNames allBridgeConfigs);
          message = "MAC addresses must be in the format XX:XX:XX:XX:XX:XX";
        }
        {
          assertion =
            let
              configuredMacs = filter (mac: mac != null) (
                map (vlanName: allBridgeConfigs.${vlanName}.macAddress) (attrNames allBridgeConfigs)
              );
              uniqueMacs = unique configuredMacs;
            in
            (length configuredMacs) == (length uniqueMacs);
          message = "All MAC addresses must be unique across all bridges";
        }
        {
          assertion = if cfg.defaultVlan != null then elem cfg.defaultVlan cfg.vlans else true;
          message = "defaultVlan must be one of the configured VLANs";
        }
      ];

      networking = {
        networkmanager.enable = false;
        useNetworkd = true;
        useDHCP = false;
        interfaces = allNetworkInterfaceConfigs;
        vlans = vlanInterfaceConfigs;
        bridges = mapAttrs' (
          vlanName: mapping: nameValuePair "br-${vlanName}" mapping
        ) bridgeToInterfaceMapping;
        defaultGateway = mkIf (primaryBridgeName != null) {
          address = if cfg.defaultVlan != null then getGatewayIp cfg.defaultVlan else getGatewayIp "lan";
          interface = if cfg.defaultVlan != null then "br-${cfg.defaultVlan}" else primaryBridgeName;
        };
      };

      boot.kernel.sysctl = mkIf cfg.disableBridgeFiltering {
        "net.bridge.bridge-nf-call-iptables" = 0;
        "net.bridge.bridge-nf-call-ip6tables" = 0;
        "net.bridge.bridge-nf-call-arptables" = 0;
      };
    };
}
