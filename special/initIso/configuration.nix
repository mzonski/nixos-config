{
  modulesPath,
  lib,
  delib,
  system,
  ...
}:
delib.host {
  name = "init";
  rice = "homelab";
  type = "minimal";

  homeManagerSystem = system;
  home.home.stateVersion = "24.11";

  myconfig = {
    admin.username = "nixos";

    hardware = {
      block.defaultScheduler = "kyber";
      block.defaultSchedulerRotational = "bfq";
    };
  };

  nixos = {
    nixpkgs.hostPlatform = system;
    system.stateVersion = "24.11";

    imports = [
      (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    ];

    isoImage.isoBaseName = lib.mkForce "init-live";
    networking.hostName = lib.mkForce "init-live";
    boot.loader.timeout = lib.mkForce 10;
    boot.loader.systemd-boot.enable = lib.mkForce false;
    services.openssh.settings.PermitRootLogin = lib.mkForce "yes";
    services.openssh.settings.PasswordAuthentication = lib.mkForce true;

    users.users.nixos = {
      initialHashedPassword = lib.mkForce null;
      initialPassword = lib.mkForce "nixos";
      openssh.authorizedKeys.keys = [
        (builtins.readFile ../../keys/hosts/corn/ssh.pub)
        (builtins.readFile ../../keys/hosts/sesame/ssh.pub)
      ];
    };

    isoImage.squashfsCompression = "gzip";

    networking.useDHCP = lib.mkDefault true;
    networking.firewall.enable = false;

    services.openssh.enable = true;
    services.openssh.knownHosts = {
      "corn" = {
        publicKey = builtins.readFile ../../keys/hosts/corn/ssh.pub;
        hostNames = [
          "corn"
          "corn.local.home.pl"
        ];
      };
      "sesame" = {
        publicKey = builtins.readFile ../../keys/hosts/sesame/ssh.pub;
        hostNames = [
          "sesame"
          "sesame.local.home.pl"
        ];
      };
    };
  };
}
