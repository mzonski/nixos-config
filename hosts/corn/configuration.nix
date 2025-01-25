{
  delib,
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
      block.defaultScheduler = "mq-deadline";
    };

    features = {
      autologin.enable = true;
      gaming.enable = true;
      virt-manager.enable = true;
    };

    programs.wayland.enable = true;
    programs.wayland.hyprland.source = "input";
    programs.docker.enable = true;
  };

  nixos = {
    nixpkgs.hostPlatform = system;
    system.stateVersion = "24.11";

    imports = [
      inputs.nixos-hardware.nixosModules.common-cpu-intel-cpu-only
      inputs.nixos-hardware.nixosModules.common-pc-ssd
    ];

    # host = {
    #   admin = "zonni";
    #   domain = "local.zonni.pl";
    # };

    boot.kernelPackages = pkgs.linuxPackages_6_12;

    # windows.variant = "hyprland";
    # windows.hyprland.source = "input";

    # virtualisation.docker.enable = true;

    networking.firewall.enable = false; # Disable firewall

    services.tumbler.enable = true; # Enable thumbnail service

    services.libinput.enable = true;
    services.openssh.enable = true;
    services.printing.enable = true;
    services.pcscd.enable = true;

    services.pipewire.enable = true;
    hardware.bluetooth.enable = true;

    programs.nix-ld.enable = false;
    programs.dconf.enable = true;
    programs.zsh.enable = true;
    #programs.gnupg.agent.enable = true;

    security.polkit.enable = true;

  };
}
