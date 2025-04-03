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
      docker.enable = false;
      windows-data-partition.enable = true;
      windows-data-partition.diskUuid = "1E08506F08504843";
    };

    programs.chrome.enable = true;
    programs.gnome.enable = true;
  };

  nixos = {
    nixpkgs.hostPlatform = system;
    system.stateVersion = "24.11";

    imports = [
      inputs.nixos-hardware.nixosModules.common-cpu-intel-cpu-only
      inputs.nixos-hardware.nixosModules.common-pc-ssd
    ];

    systemd.package = pkgs.unstable.systemd;

    # boot.kernelParams = [
    #   "freezer.no_user_freeze=1" # Prevents the freezer cgroup from freezing user processes
    # ];

    # # https://github.com/kachick/dotfiles/issues/959#issuecomment-2533264029
    systemd.services.systemd-suspend.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";

    systemd.services.nvidia-hibernate.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
    systemd.services.nvidia-suspend.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
    systemd.services.pre-sleep.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
    systemd.services.post-resume.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
    systemd.services.systemd-hibernate-clear.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
    systemd.services.systemd-hibernate.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
    systemd.services.systemd-hybrid-sleep.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
    systemd.services.systemd-suspend-then-hibernate.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS =
      "false";

    # systemd.sleep.extraConfig = ''
    #   SuspendState=freeze
    # '';

    # # https://gitlab.archlinux.org/archlinux/packaging/packages/nvidia-utils/-/commit/b9ddd997381f9552131862320dcc8c4b45a60708#note_192390
    systemd.services.homed-hibernate.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
    systemd.services.homed-hybrid-sleep.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
    systemd.services.homed-suspend-then-hibernate.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS =
      "false";

    # TODO: REVERT IT
    boot.readOnlyNixStore = false;
    # TODO: REVERT IT

    #boot.kernelPackages = pkgs.linuxPackages_latest;
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
