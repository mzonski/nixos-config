{
  config,
  modulesPath,
  lib,
  pkgs,
  delib,
  host,
  homeManagerUser,
  ...
}:
let
  inherit (import ../../lib/env.nix { inherit lib; }) requireEnvVar;
in
delib.module {
  name = "graft";

  myconfig.always = {
    boot.enable = lib.mkForce false;
  };

  nixos.always = {
    imports = [ (modulesPath + "/installer/cd-dvd/iso-image.nix") ];

    systemd.tmpfiles.rules = [
      "d /home/${homeManagerUser}/.ssh 0700 ${homeManagerUser} ${homeManagerUser} - -"
    ];

    image.baseName = lib.mkForce "graft-${host.name}";
    isoImage.isoBaseName = lib.mkForce "graft-${host.name}";
    isoImage.squashfsCompression = "zstd -Xcompression-level 6";

    hardware.enableAllHardware = true;
    isoImage.makeEfiBootable = true;
    isoImage.makeUsbBootable = true;
    swapDevices = lib.mkImageMediaOverride [ ];
    fileSystems = lib.mkImageMediaOverride config.lib.isoFileSystems;
    boot.initrd.luks.devices = lib.mkImageMediaOverride { };

    boot.nixStoreMountOpts = [
      "rw"
      "nodev"
      "nosuid"
    ];

    boot.initrd.systemd.services.graft-ssh-host-keys = {
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
  };
}
