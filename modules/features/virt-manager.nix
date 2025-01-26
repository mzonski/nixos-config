{
  lib,
  pkgs,
  delib,
  ...
}:

let
  inherit (lib) mkDefault;
  inherit (delib)
    module
    strOption
    boolOption
    ;
  virtdGroupName = "libvirtd";
in
module {
  name = "features.virt-manager";

  options.features.virt-manager = {
    enable = boolOption false;
    macAddress = strOption "00:00:00:00:00:01";
    virtualBridgeNetwork = strOption "192.168.122.0/24";
    virtualBridgeInterface = strOption "virbr0";
    bridgeInterface = strOption "br0";
    externalInterface = strOption "enp3s0";
  };

  myconfig.ifEnabled.user.groups = [ virtdGroupName ];

  nixos.ifEnabled =
    { cfg, myconfig, ... }:
    let
      inherit (myconfig.admin) username;
    in
    {
      boot.kernelParams = [
        "intel_iommu=on"
        "iommu=pt"
      ];

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
            verbatimConfig = ''
              user = "${username}"
              group = "${virtdGroupName}"
              nvram = ["/run/libvirt/nix-ovmf/OVMF_CODE.fd:/run/libvirt/nix-ovmf/OVMF_VARS.fd"]
              gl = 1
              egl_headless = 1
              spice_gl = 1
              display_gl = 1
            '';
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
        useDHCP = mkDefault true;

        networkmanager.unmanaged = [
          cfg.bridgeInterface
          cfg.externalInterface
        ];

        useNetworkd = mkDefault true;

        bridges = {
          "${cfg.bridgeInterface}" = {
            interfaces = [ cfg.externalInterface ];
          };
        };

        interfaces = {
          "${cfg.externalInterface}".useDHCP = mkDefault false;
          "${cfg.bridgeInterface}" = {
            useDHCP = mkDefault true;
            macAddress = mkDefault cfg.macAddress;
          };
        };
      };
    };

  home.ifEnabled = {
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = [ "qemu:///system" ];
        uris = [ "qemu:///system" ];
      };
    };
  };

}
