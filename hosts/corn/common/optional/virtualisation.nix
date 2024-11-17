{ pkgs, lib, ... }:
let
  macAddress = "00:00:00:00:00:01";
  virtualBridgeNetwork = "192.168.122.0/24";
  virtualBridgeInterface = "virbr0";
  bridgeInterface = "br0";
  externalInterface = "enp3s0";
in
{
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
    externalInterface = externalInterface;
    internalInterfaces = [ virtualBridgeInterface ];
    internalIPs = [ virtualBridgeNetwork ];
  };

  networking = {
    useDHCP = lib.mkDefault true;

    networkmanager.unmanaged = [
      bridgeInterface
      externalInterface
    ];

    useNetworkd = lib.mkDefault true;

    bridges = {
      "${bridgeInterface}" = {
        interfaces = [ externalInterface ];
      };
    };

    interfaces = {
      "${externalInterface}".useDHCP = lib.mkDefault false;
      "${bridgeInterface}" = {
        useDHCP = lib.mkDefault true;
        macAddress = lib.mkDefault macAddress;
      };
    };
  };
}
