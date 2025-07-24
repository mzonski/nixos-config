{
  config,
  modulesPath,
  lib,
  delib,
  system,
  homeManagerUser,
  ...
}:
let
  inherit (import ../../lib/env.nix { inherit lib; }) requireEnvVar;
in
delib.host {
  name = "seed";
  rice = "homelab";
  type = "minimal";

  homeManagerSystem = system;
  home.home.stateVersion = "25.05";

  myconfig = {
    admin.username = homeManagerUser;
  };

  nixos = {
    isoImage.isoBaseName = lib.mkForce "seed";

    boot.readOnlyNixStore = false;
    boot.loader.timeout = lib.mkForce 10;
    boot.loader.systemd-boot.enable = lib.mkForce false;

    nixpkgs.hostPlatform = system;
    system.stateVersion = "25.05";

    imports = [
      (modulesPath + "/installer/cd-dvd/installation-cd-base.nix")
      (modulesPath + "/profiles/qemu-guest.nix")
    ];

    environment.etc = {
      "ssh/ssh_host_ed25519_key" = {
        # need to add next line, if not added ssh dont initialize on boot
        text = ''
          ${requireEnvVar "SSH_PRIVATE_HOST"}
            
        '';
        mode = "0600";
      };
      "ssh/ssh_host_ed25519_key.pub" = {
        text = ''
          ${requireEnvVar "SSH_PUBLIC_HOST"}
            
        '';
        mode = "0640";
      };
    };

    services.openssh = {
      settings.PermitRootLogin = lib.mkForce "yes";
      enable = true;
    };
    services.spice-vdagentd.enable = true;
    services.qemuGuest.enable = true;

    networking = {
      hostName = lib.mkForce config.isoImage.isoBaseName;
      firewall.enable = false;
    };
    networking.useDHCP = lib.mkForce false;
    systemd.network = {
      enable = true;
      networks."10-home" = {
        matchConfig = {
          Name = "en* eth* enp* ens*";
          Type = "ether";
        };
        networkConfig = {
          DHCP = "no";
          Address = "10.0.1.49/24";
          Gateway = "10.0.1.1";
        };
      };
    };

    users.users.nixos = {
      initialHashedPassword = lib.mkForce null;
      hashedPasswordFile = lib.mkForce null;
      initialPassword = lib.mkForce "nixos";
    };

    isoImage.squashfsCompression = "gzip";

    sops.secrets = {
      "ssh_public_corn" = {
        path = "/etc/ssh/authorized_keys.d/root";
        mode = "0640";
        owner = "root";
        group = "root";
      };
    };

    services.openssh = {
      authorizedKeysFiles = ([
        config.sops.secrets.ssh_public_zonni.path
        config.sops.secrets.ssh_public_corn.path
      ]);
    };
  };

  home = {
    programs.ssh = {
      enable = true;
    };
  };
}
