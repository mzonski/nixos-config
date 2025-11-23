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
  rice = "catppuccin-sharp-dark";
  type = "desktop";
  secretsFile = ./secrets.yaml;

  homeManagerSystem = system;
  home.home.stateVersion = "25.05";

  myconfig =
    { myconfig, ... }:
    {
      admin.username = "zonni";

      hardware = {
        audio.enable = true;
        bluetooth.enable = false;
        block.defaultScheduler = "kyber";
        block.defaultSchedulerRotational = "bfq";
        logitech.enable = true;
      };

      features = {
        autologin.enable = false;
        autologin.session = "Hyprland";
        gaming.enable = true;
        general-development.enable = true;
        docker.enable = true;
        windows-data-partition.enable = false;
        windows-data-partition.diskUuid = "1E08506F08504843";
        low-latency.enable = true;
        vpnclient.enable = false;
        virt-manager = {
          enable = true;
          bridge.enable = false;
          bridge.externalInterface = "enp113s0";
          vfio-passtrough = {
            enable = true;
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
      programs.gdm.enable = lib.mkForce true;
      programs.sddm.enable = lib.mkForce false;
      programs.hyprland.enable = false;
      programs.hyprland.source = "stable";
      programs.gnome.enable = true;
      programs.gnome.fullInstall = true;
      programs.gnome.freezeOnNvidiaSuspend.enable = true;

      hardware.network.restart-after-suspend = {
        enable = true;
        networkInterface = "enp113s0";
      };
      hardware.deepcool-digital-linux.enable = false;
      hardware.my-pc-rgb.enable = true;

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
    system.stateVersion = "25.05";
    hardware.enableRedistributableFirmware = true;

    imports = [
      inputs.nixos-hardware.nixosModules.common-pc-ssd
    ];

    #boot.readOnlyNixStore = false;

    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.loader.systemd-boot.windows."11".efiDeviceHandle = "HD1e";

    services.tumbler.enable = true; # Enable thumbnail service

    services.openssh.enable = true;
    services.printing.enable = true;

    programs.nix-ld.enable = false;
    programs.dconf.enable = true;

    security.polkit.enable = true;

    services.scx.enable = true;
    services.scx.scheduler = "scx_rusty";

    hardware.i2c.enable = true;

    services.udev.packages = [
      (pkgs.writeTextDir "etc/udev/rules.d/45-asus-peripherals.rules" (''
        # ASUS ROG RYUJIN III EXTREME
        SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0b05", ATTRS{idProduct}=="1bcb", MODE="0666", OWNER="zonni"
      ''))
    ];
  };

  home = {
    programs = {
      bash.enable = true;
      bat.enable = true;

      git = {
        userName = "Maciej Zonski";
        userEmail = "me@zonni.pl";
      };
    };
  };
}
