{
  delib,
  lib,
  inputs,
  system,
  pkgs,
  ...
}:
delib.host {
  name = "corn";
  rice = "kde-breeze";
  type = "desktop";
  secretsFile = ./secrets.yaml;

  homeManagerSystem = system;
  home.home.stateVersion = "26.05";

  myconfig =
    { myconfig, ... }:
    {
      admin.username = "zonni";
      boot.windowsDiskId = "0A13-7DD7";

      hardware = {
        audio.enable = true;
        bluetooth.enable = true;
        block.defaultScheduler = "kyber";
        block.defaultSchedulerRotational = "bfq";
        logitech.enable = true;
      };

      features = {
        ai.enable = true;
        gaming.enable = true;
        general-development.enable = true;
        docker.enable = true;
        virt-manager = {
          enable = true;
          bridge.enable = false;
          bridge.externalInterface = "enp113s0";
          allowedDevices = [
            "/dev/dri/card0"
            "/dev/dri/renderD128"
            "/dev/dri/card1"
            "/dev/dri/renderD129"
            "/dev/nvidia0"
            "/dev/nvidiactl"
          ];
          vfio-passtrough = {
            enable = false;
            devices = {
              dgpu-video = "10de:2b85";
              dgpu-audio = "10de:22e8";
              igd-video = "1002:13c0";
            };
            scripts.hooks = {
              postGpuToNvidia = myconfig.services.coolercontrol.scripts.restartAndSetModeGpu;
              preGpuToVfio = myconfig.services.coolercontrol.scripts.stop;
              postGpuToVfio = myconfig.services.coolercontrol.scripts.restartAndSetModeCpu;
            };
          };
        };
      };

      services.coolercontrol = {
        enable = true;
        setModeOnTerminate.targetModeId = "e7de53fd-c644-4959-b299-8ad13a92be23";
        scripts.setModeCpu.targetModeId = "e7de53fd-c644-4959-b299-8ad13a92be23";
        scripts.setModeGpu.targetModeId = "5ff2d15b-420f-43c8-8e55-46ca66145d48";
      };

      programs.chrome.enable = true;
      programs.kde.enable = true;
      hardware.my-pc-rgb.enable = false;

      services.network-share-client = {
        enable = true;
        mounts = [
          {
            resource = "tomato:/nas/media";
            target = "/mnt/nas/media";
          }
          {
            resource = "tomato:/nas/files";
            target = "/mnt/nas/files";
          }
        ];
      };

      services.nginx.enable = true;

      homelab.enable = true;
      homelab.networking = {
        enable = true;
        defaultVlan = "home";
        defaultOctet = 50;
        vlans = {
          home.macAddress = "00:00:00:00:00:01";
          vpn.macAddress = "00:00:00:00:00:02";
        };
      };
    };

  nixos = {
    nixpkgs.hostPlatform = system;
    system.stateVersion = "26.05";
    hardware.enableRedistributableFirmware = true;

    imports = [
      inputs.nixos-hardware.nixosModules.common-pc-ssd
    ];

    #boot.readOnlyNixStore = false;

    #boot.kernelPackages = pkgs.linuxPackages_latest;
    #boot.kernelPackages = pkgs.linuxPackages_zen;

    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-x86_64-v4;
    boot.loader.grub.memtest86.enable = true;

    services.tumbler.enable = true; # Enable thumbnail service

    services.openssh.enable = true;
    services.printing.enable = true;

    programs.nix-ld.enable = false;
    programs.dconf.enable = true;

    security.polkit.enable = true;

    services.scx.enable = true;
    services.scx.scheduler = "scx_bpfland";

    hardware.i2c.enable = true;
  };

  home = {
    programs = {
      bash.enable = true;
      bat.enable = true;
    };
  };
}
