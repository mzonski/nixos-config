{
  delib,
  inputs,
  system,
  pkgs,
  ...
}:
delib.host {
  name = "sesame";
  rice = "catppuccin-sharp-dark";
  type = "desktop";

  homeManagerSystem = system;
  home.home.stateVersion = "25.11";

  myconfig = {
    admin.username = "zonni";

    hardware = {
      audio.enable = true;
      bluetooth.enable = true;
      block.defaultScheduler = "kyber";
      block.defaultSchedulerRotational = "bfq";
      storage = {
        enable = true;
        layout = "desktop_btrfs_single_disk";
        devices = [
          "/dev/disk/by-id/nvme-INTEL_SSDPEKNW512G8_BTNH03530LMA512A"
        ];
        swapSize = "32G";
      };
      logitech.enable = true;
      battery-threshold = {
        enable = true;
        threshold = 60;
        batteryId = "BAT0";
      };
    };

    features = {
      autologin.enable = false;
      autologin.session = "gnome";
      gaming.enable = false;
      general-development.enable = false;
      virt-manager.enable = false;
      docker.enable = false;
      windows-data-partition.enable = false;
      vpnclient.enable = false;
    };

    programs.chrome.enable = true;
    programs.gnome.enable = true;
    programs.jetbrains.enable = false;
    programs.utils.mitmproxy = {
      enable = true;
      interface = "wlo1";
    };
  };

  nixos = {
    nixpkgs.hostPlatform = system;
    system.stateVersion = "25.11";
    boot.kernelPackages = pkgs.linuxPackages_zen;

    imports = [
      inputs.nixos-hardware.nixosModules.common-cpu-intel
      inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
    ];

    services.tumbler.enable = true;
    services.libinput.enable = true;
    services.openssh.enable = true;
    services.printing.enable = true;
    security.polkit.enable = true;

    hardware.i2c.enable = true;

    services.logind.settings.Login = {
      HandleLidSwitch = "sleep";
      HandleLidSwitchExternalPower = "sleep";
      HandleLidSwitchDocked = "sleep";

      HandlePowerKey = "poweroff";
      HandlePowerKeyLongPress = "poweroff";

      InhibitDelayMaxSec = 5;
      LidSwitchIgnoreInhibited = true;
      PowerKeyIgnoreInhibited = false;
      SuspendKeyIgnoreInhibited = true;
      HibernateKeyIgnoreInhibited = true;

      SleepOperation = "suspend-then-hibernate suspend hibernate";
    };

    services.upower.ignoreLid = true;
  };

  home = {
    programs = {
      bash.enable = true;
      bat.enable = true;
    };
  };
}
