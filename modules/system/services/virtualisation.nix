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
  inherit (config.sys) username;
  virtdGroupName = "libvirtd";
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

    sys.user.extraGroups = [ virtdGroupName ];

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
