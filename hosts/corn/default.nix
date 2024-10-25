{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-gpu-nvidia
    inputs.hardware.nixosModules.common-pc-ssd

    ./boot.nix
    ./display.nix

    ./hardware-configuration.nix

    ../common/global
    ../common/users.nix

    ../common/optional/gnome.nix
    ../common/optional/pipewire.nix
  ];

  environment.systemPackages = with pkgs; [
    hello
    wget
    curl
    lshw
    gnumake
    pciutils
    aha
    clinfo
    libglvnd
    glxinfo
    vulkan-tools
    wayland-utils
    fwupd
  ];

  networking = {
    hostName = "corn";
    useDHCP = true;
    firewall.enable = false;
  };

  programs = {
    dconf.enable = true;
  };

  services.openssh.enable = true;
  services.printing.enable = true;
  services.pcscd.enable = true;

  #hardware.graphics.enable = true;

  system.stateVersion = "24.05";
}
