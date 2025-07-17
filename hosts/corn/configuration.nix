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
      virt-manager.externalInterface = "enp113s0";
      docker.enable = true;
      windows-data-partition.enable = false;
      windows-data-partition.diskUuid = "1E08506F08504843";
      low-latency.enable = true;
      home-nas.enable = true;
    };

    programs.chrome.enable = true;
    programs.gdm.enable = lib.mkForce true;
    programs.sddm.enable = lib.mkForce false;
    programs.hyprland.enable = false;
    programs.hyprland.source = "stable";
    programs.gnome.enable = true;
    programs.gnome.fullInstall = true;
    programs.gnome.freezeOnNvidiaSuspend.enable = false;
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

    boot.kernelPackages = pkgs.unstable.linuxPackages_latest;
    #boot.kernelPackages = pkgs.linuxPackages_6_12;
    networking.firewall.enable = false; # Disable firewall

    services.tumbler.enable = true; # Enable thumbnail service

    services.libinput.enable = true;
    services.openssh.enable = true;
    services.printing.enable = true;

    programs.nix-ld.enable = false;
    programs.dconf.enable = true;

    security.polkit.enable = true;

    services.scx.enable = true;
    services.scx.scheduler = "scx_rusty";

    services.hardware.openrgb.enable = true;
    hardware.i2c.enable = true;
    programs.coolercontrol.enable = true;
    programs.coolercontrol.nvidiaSupport = true;

    # boot.kernelParams = [
    # "acpi_enforce_resources=lax"
    # ];
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
