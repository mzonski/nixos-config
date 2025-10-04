{
  config,
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

  homeManagerSystem = system;
  home.home.stateVersion = "25.05";

  myconfig = {
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
      virt-manager.enable = true;
      virt-manager.bridge.enable = true;
      virt-manager.vfio-passtrough.enable = true;
      virt-manager.bridge.externalInterface = "enp113s0";
      docker.enable = true;
      windows-data-partition.enable = false;
      windows-data-partition.diskUuid = "1E08506F08504843";
      low-latency.enable = true;
      home-nas.enable = true;
      vpnclient.enable = false;
    };

    programs.chrome.enable = true;
    programs.gdm.enable = lib.mkForce true;
    programs.sddm.enable = lib.mkForce false;
    programs.hyprland.enable = false;
    programs.hyprland.source = "stable";
    programs.gnome.enable = true;
    programs.gnome.fullInstall = true;
    programs.gnome.freezeOnNvidiaSuspend.enable = true;

    services.systemd.restart-network-after-suspend = {
      enable = true;
      networkInterface = "enp113s0";
    };
    services.deepcool-digital-linux.enable = true;
  };

  nixos = {
    nixpkgs.hostPlatform = system;
    system.stateVersion = "25.05";
    hardware.enableRedistributableFirmware = true;

    imports = [
      inputs.nixos-hardware.nixosModules.common-pc-ssd
    ];

    # CHANGE TO boot.nixStoreMountOpts
    boot.readOnlyNixStore = false;
    # TODO: REVERT IT

    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.loader.systemd-boot.windows."11".efiDeviceHandle = "HD1b";

    networking.firewall.enable = false; # Disable firewall

    services.tumbler.enable = true; # Enable thumbnail service

    services.openssh.enable = true;
    services.printing.enable = true;

    programs.nix-ld.enable = false;
    programs.dconf.enable = true;

    security.polkit.enable = true;

    services.scx.enable = true;
    services.scx.scheduler = "scx_rusty";

    services.hardware.openrgb.enable = true;
    hardware.i2c.enable = true;
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
