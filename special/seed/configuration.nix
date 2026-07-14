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
  home.home.stateVersion = "26.05";

  myconfig = {
    admin.username = homeManagerUser;
  };

  nixos = {
    image.baseName = lib.mkForce "seed";
    isoImage.isoBaseName = lib.mkForce "seed";

    boot.nixStoreMountOpts = [
      "rw"
      "nodev"
      "nosuid"
    ];

    boot.loader.timeout = lib.mkForce 10;
    boot.loader.systemd-boot.enable = lib.mkForce false;

    nixpkgs.hostPlatform = system;
    system.stateVersion = "26.05";

    imports = [
      (modulesPath + "/installer/cd-dvd/installation-cd-base.nix")
      (modulesPath + "/profiles/qemu-guest.nix")
    ];

    boot.initrd.systemd.services.seed-ssh-host-keys = {
      wantedBy = [ "initrd.target" ];
      after = [ "sysroot.mount" ];
      before = [ "initrd-switch-root.target" ];
      unitConfig.DefaultDependencies = false;
      unitConfig.RequiresMountsFor = [ "/sysroot" ];
      serviceConfig.Type = "oneshot";
      script = ''
            mkdir -p /sysroot/etc/ssh
            umask 077
            cat > /sysroot/etc/ssh/ssh_host_ed25519_key <<'EOF'
        ${requireEnvVar "SSH_PRIVATE_HOST"}
        EOF
            cat > /sysroot/etc/ssh/ssh_host_ed25519_key.pub <<'EOF'
        ${requireEnvVar "SSH_PUBLIC_HOST"}
        EOF
            chmod 600 /sysroot/etc/ssh/ssh_host_ed25519_key
            chmod 644 /sysroot/etc/ssh/ssh_host_ed25519_key.pub
      '';
    };

    services.openssh = {
      settings.PermitRootLogin = lib.mkForce "yes";
      settings.PasswordAuthentication = lib.mkForce false;
      enable = true;
    };
    services.spice-vdagentd.enable = true;
    services.qemuGuest.enable = true;

    networking = {
      hostName = lib.mkForce config.isoImage.isoBaseName;
      firewall.enable = lib.mkForce false;
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

    sops.secrets.user_zonni_password.neededForUsers = true;

    users.mutableUsers = lib.mkForce false;
    users.users.nixos = {
      hashedPasswordFile = config.sops.secrets.user_zonni_password.path;
      hashedPassword = lib.mkForce null;
      initialHashedPassword = lib.mkForce null;
      initialPassword = lib.mkForce null;
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

    networking.wireless.enable = true;

    services.openssh = {
      authorizedKeysFiles = ([
        config.sops.secrets.ssh_public_zonni.path
        config.sops.secrets.ssh_public_corn.path
      ]);
    };
  };
}
