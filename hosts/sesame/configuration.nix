{
  delib,
  inputs,
  system,
  ...
}:
delib.host {
  name = "sesame";
  rice = "catppuccin-sharp-dark";
  type = "desktop";

  homeManagerSystem = system;
  home.home.stateVersion = "24.11";

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
    };

    features = {
      autologin.enable = false;
      autologin.session = "hyprland";
      gaming.enable = false;
      general-development.enable = false;
      virt-manager.enable = false;
      docker.enable = false;
      windows-data-partition.enable = false;
    };

    programs.chrome.enable = true;
    programs.wayland = {
      hyprland.source = "stable";
      idle = {
        lockEnabled = false;
        lockTimeout = 10 * 60; # 10 min
        turnOffDisplayTimeout = 5 * 60; # 5 min
        suspendTimeout = 30 * 60; # 30 min
      };
    };
  };

  nixos = {
    nixpkgs.hostPlatform = system;
    system.stateVersion = "24.11";

    imports = [
      inputs.nixos-hardware.nixosModules.common-cpu-intel
      inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
    ];

    boot.readOnlyNixStore = false;

    networking.firewall.enable = false;

    services.tumbler.enable = true;

    services.libinput.enable = true;
    services.openssh.enable = true;
    services.printing.enable = true;
    security.polkit.enable = true;
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
