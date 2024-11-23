{ inputs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel-cpu-only
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    ./boot.nix
    ./file-system.nix

    ./common/optional/hyprland.nix
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
    shell.zsh.enable = true;

    services = {
      quietboot.enable = false;
      virtualisation.enable = true;
      virtual-filesystem.gvfs = true;
    };
  };

  networking.firewall.enable = false;

  programs.dconf.enable = true;

  services.libinput.enable = true;
  services.openssh.enable = true;
  services.printing.enable = true;
  services.pcscd.enable = true;
}
