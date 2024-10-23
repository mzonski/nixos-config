# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    ./boot.nix
    ./display.nix
    ./hardware-configuration.nix
    ./locale.nix
    ./users.nix
  ];

  nixpkgs = {
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
      settings = {
        # Enable flakes and new 'nix' command
        experimental-features = "nix-command flakes";
        # Opinionated: disable global registry
        flake-registry = "";
        # Workaround for https://github.com/NixOS/nix/issues/9574
        nix-path = config.nix.nixPath;
      };
      # Opinionated: disable channels
      channel.enable = false;

      # Opinionated: make flake registry and nix path match flake inputs
      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    };

  networking = {
    firewall.enable = false;
    networkmanager.enable = true;
  };

  # Desktop Environment and Display Configuration
  services.xserver.enable = true;

  # Gnome
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Audio Configuration
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Auto Login Configuration
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "zonni";

  # GNOME Autologin Workaround
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Package Configuration
  environment.systemPackages = with pkgs; [
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

  # Programs Configuration
  programs = {
    firefox.enable = true;
    git.enable = true;
    git.config.init.defaultBranch = "main";
  };

  # Services Configuration
  services.openssh.enable = true;
  services.printing.enable = true;
  services.pcscd.enable = true;

  services.acpid.enable = true;
  services.thermald.enable = true;
  services.power-profiles-daemon.enable = true;

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
