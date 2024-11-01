{
  inputs,
  modulesPath,
  lib,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")

    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-gpu-nvidia
    inputs.hardware.nixosModules.common-pc-ssd

    ./boot.nix
    ./file-system.nix
    ./graphics.nix

    ../common/global
    ../common/users.nix

    ../common/optional/gnome.nix
    ../common/optional/pipewire.nix
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  networking.hostName = "corn";
  networking.useDHCP = true;
  networking.firewall.enable = false;

  programs.dconf.enable = true;

  services.openssh.enable = true;
  services.printing.enable = true;
  services.pcscd.enable = true;

  system.stateVersion = "24.11";
}
