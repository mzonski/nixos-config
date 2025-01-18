{
  host = {
    admin = "zonni";
    domain = "local.zonni.pl";
  };

  features = {
    quietboot.enable = false;
    autologin.enable = true;
    gaming.enable = true;
    virtualisation.enable = true;
  };

  boot.loader.systemd-boot.enable = true;

  windows.variant = "hyprland";
  windows.hyprland.source = "input";

  networking.firewall.enable = false; # Disable firewall

  services.tumbler.enable = true; # Enable thumbnail service

  services.libinput.enable = true;
  services.openssh.enable = true;
  services.printing.enable = true;
  services.pcscd.enable = true;

  services.gvfs.enable = true; # virtual filesystem (ex. Trash)

  services.pipewire.enable = true;
  hardware.bluetooth.enable = true;

  programs.nix-ld.enable = false;
  programs.dconf.enable = true;
  programs.zsh.enable = true;
  programs.gnupg.agent.enable = true;
}
