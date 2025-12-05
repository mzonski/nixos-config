{ pkgs, delib, ... }:
let
  inherit (delib)
    module
    packageOption
    noNullDefault
    allowNull
    noDefault
    strOption
    intOption
    boolOption
    ;
  qemuGroupName = "qemu-libvirtd";
in
module {
  name = "features.virt-manager";

  options.features.virt-manager = {
    enable = boolOption false;

    bridge = {
      enable = boolOption false;

      macAddress = strOption "00:00:00:00:00:01";
      virtualBridgeNetwork = strOption "192.168.122.0/24";
      virtualBridgeInterface = strOption "virbr0";
      bridgeInterface = strOption "br0";
      externalInterface = strOption "enp3s0";
    };

    vfio-passtrough = {
      enable = boolOption false;
      sharedMemorySize = intOption 256;
      autoBindDevices = boolOption false;

      devices = {
        dgpu-video = strOption "10de:2488";
        dgpu-audio = strOption "10de:228b";
        igd-video = strOption "1002:13c0";
      };
      scripts = {
        gpu-status = noDefault (packageOption null);
        gpu-to-nvidia = noDefault (packageOption null);
        gpu-to-vfio = noDefault (packageOption null);
        hooks = {
          preGpuToNvidia = allowNull (packageOption null);
          postGpuToNvidia = allowNull (packageOption null);
          preGpuToVfio = allowNull (packageOption null);
          postGpuToVfio = allowNull (packageOption null);
        };
      };
    };
  };

  myconfig.ifEnabled.user.groups = [
    qemuGroupName
  ];

  nixos.ifEnabled =
    { cfg, myconfig, ... }:
    let
      inherit (myconfig.admin) username;
    in
    {
      boot.kernelParams = [
        "amd_iommu=on"
        "iommu=pt"
      ];

      programs.virt-manager.enable = true;

      environment.systemPackages = with pkgs; [
        virt-viewer
        spice
        spice-protocol
        virtio-win
        win-spice
      ];

      virtualisation = {
        libvirtd = {
          enable = true;
          qemu = {
            package = pkgs.qemu_kvm;
            runAsRoot = true;
            swtpm.enable = true;
            # ovmf.enable = true;
            # ovmf.packages = [ pkgs.OVMFFull.fd ];
            verbatimConfig = ''
              user = "${username}"
              group = "${qemuGroupName}"
              gl = 1
              egl_headless = 1
              spice_gl = 1
              display_gl = 1
            '';
          };
        };
        spiceUSBRedirection.enable = true;
      };
    };
}
