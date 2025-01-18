{
  sys = {
    adminUser = "zonni";
    domain = "local.zonni.pl";
    hardware = {
      audio.enable = true;
      graphics.nvidia.enable = true;
    };
    apps.cli.zsh = true;

    services = {
      virtualisation.enable = true;
    };

    shell.gnupg.enable = true;

    gaming.enable = true;
  };

  boot.quietboot = false;
  boot.loader.systemd-boot.enable = true;

  windows.variant = "hyprland";
  windows.hyprland.source = "input";

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

  programs.nix-ld.enable = false;
}
