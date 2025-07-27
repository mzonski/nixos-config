{
  host,
  delib,
  config,
  lib,
  ...
}:
let

  inherit (delib) module singleEnableOption;
in
module {
  name = "networking.wireless";

  options = singleEnableOption host.isDesktop;

  nixos.ifEnabled =
    { cfg, ... }:
    {
      sops.secrets = {
        wifi_ssid = { };
        wifi_psk = { };
        wifi_ssid_hex = { };
      };

      sops.templates.systemd-network-wifi = {
        content = ''
          wifi_ssid=${config.sops.placeholder.wifi_ssid}
          wifi_psk=${config.sops.placeholder.wifi_psk}
        '';
        path = "/etc/wifi.conf";
      };

      networking.wireless = {
        secretsFile = config.sops.templates.systemd-network-wifi.path;
        networks."ext:wifi_ssid".psk = "ext:wifi_psk";
      };

      sops.templates.network-manager-home-wifi = {
        content = lib.generators.toINI { } {
          connection = {
            id = config.sops.placeholder.wifi_ssid;
            uuid = "12345678-1234-1234-1234-123456789012";
            type = "wifi";
          };
          wifi = {
            mode = "infrastructure";
            ssid = config.sops.placeholder.wifi_ssid_hex;
          };
          wifi-security = {
            auth-alg = "open";
            key-mgmt = "wpa-psk";
            psk = config.sops.placeholder.wifi_psk;
          };
          ipv4 = {
            method = "auto";
          };
          ipv6 = {
            addr-gen-mode = "default";
            method = "auto";
          };
        };
        path = "/etc/NetworkManager/system-connections/home-wifi.nmconnection";
        mode = "0600";
        owner = "root";
      };
    };
}
