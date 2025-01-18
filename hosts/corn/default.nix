{ inputs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel-cpu-only
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    ./boot.nix
    ./file-system.nix
  ];

  sys = {
    username = "zonni";
    domain = "local.zonni.pl";
    hardware = {
      audio.enable = true;
      graphics.nvidia.enable = true;
    };
    locale.ponglish.enable = true;
    locale.timezone.warsaw = true;
    apps.cli.zsh = true;

    services = {
      virtualisation.enable = true;
    };

    shell.gnupg.enable = true;

    gaming.enable = true;
  };

  boot.quietboot = false;
  windows.variant = "hyprland";
  windows.hyprland.source = "unstable";

  hardware.bluetooth.enable = true;

  networking.firewall.enable = false; # Disable firewall

  programs.dconf.enable = true;
  services.tumbler.enable = true; # Enable thumbnail service

  services.libinput.enable = true;
  services.openssh.enable = true;
  services.printing.enable = true;
  services.pcscd.enable = true;

  services.autologin.enable = true;
  services.gvfs.enable = true; # virtual filesystem (ex. Trash)

  programs.nix-ld.enable = true;

}
