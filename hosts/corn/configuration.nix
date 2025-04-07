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
  home.home.stateVersion = "24.11";

  myconfig = {
    admin.username = "zonni";

    hardware = {
      audio.enable = true;
      bluetooth.enable = true;
      block.defaultScheduler = "kyber";
      block.defaultSchedulerRotational = "bfq";
    };

    features = {
      autologin.enable = false;
      autologin.session = "gnome-wayland";
      gaming.enable = true;
      general-development.enable = true;
      virt-manager.enable = false;
      docker.enable = true;
      windows-data-partition.enable = true;
      windows-data-partition.diskUuid = "1E08506F08504843";
    };

    programs.chrome.enable = true;
    programs.gnome.enable = true;
    programs.gnome.noUserSessionFreeze.enable = true;
  };

  nixos = {
    nixpkgs.hostPlatform = system;
    system.stateVersion = "24.11";

    imports = [
      inputs.nixos-hardware.nixosModules.common-cpu-intel-cpu-only
      inputs.nixos-hardware.nixosModules.common-pc-ssd
    ];

    # TODO: REVERT IT
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
