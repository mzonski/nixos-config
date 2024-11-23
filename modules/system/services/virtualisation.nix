{
  config,
  options,
  lib,
  pkgs,
  mylib,
  ...
}:

with lib;
with mylib;
let
  cfg = config.sys.services.virtualisation;
in
{
  options.sys.services.virtualisation = with types; {
    enable = mkBoolOpt false;
    macAddress = mkStrOpt "00:00:00:00:00:01";
    virtualBridgeNetwork = mkStrOpt "192.168.122.0/24";
    virtualBridgeInterface = mkStrOpt "virbr0";
    bridgeInterface = mkStrOpt "br0";
    externalInterface = mkStrOpt "enp3s0";
  };

  config = mkIf cfg.enable {

    sys.user.extraGroups = [ "libvirtd" ];

    environment.systemPackages = with pkgs; [
      virt-manager
      virt-viewer
      spice
      spice-gtk
      spice-protocol
      win-virtio
      win-spice
    ];

    virtualisation = {
      libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = true;
          swtpm.enable = true;
          ovmf.enable = true;
          ovmf.packages = [ pkgs.OVMFFull.fd ];
        };
      };
      spiceUSBRedirection.enable = true;
    };
    services.spice-vdagentd.enable = true;

    networking.nat = {
      enable = true;
      enableIPv6 = false;
      externalInterface = cfg.externalInterface;
      internalInterfaces = [ cfg.virtualBridgeInterface ];
      internalIPs = [ cfg.virtualBridgeNetwork ];
    };

    networking = {
      useDHCP = lib.mkDefault true;

      networkmanager.unmanaged = [
        bridgeInterface
        externalInterface
      ];

      useNetworkd = lib.mkDefault true;

      bridges = {
        "${cfg.bridgeInterface}" = {
          interfaces = [ cfg.externalInterface ];
        };
      };

      interfaces = {
        "${cfg.externalInterface}".useDHCP = lib.mkDefault false;
        "${cfg.bridgeInterface}" = {
          useDHCP = lib.mkDefault true;
          macAddress = lib.mkDefault cfg.macAddress;
        };
      };
    };
  };
}
