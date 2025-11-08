{
  delib,
  inputs,
  system,
  ...
}:
delib.host {
  name = "tomato";
  rice = "homelab";
  type = "server";

  homeManagerSystem = system;
  home.home.stateVersion = "25.05";

  myconfig = {
    admin.username = "zonni";
    admin.disableSudoPasswordRequirement = true;

    hardware = {
      audio.enable = false;
      bluetooth.enable = false;
      block.defaultScheduler = "kyber";
      block.defaultSchedulerRotational = "bfq";
      storage = {
        enable = true;
        layout = "server_single_xfs";
        devices = [
          "/dev/disk/by-id/nvme-Lexar_SSD_NM710_500GB_NFS401R004945P2200"
        ];
        swapSize = "16G";
      };
    };

    features = {
      virt-manager.enable = false;
      docker.enable = true;
    };
  };

  nixos = {
    nixpkgs.hostPlatform = system;
    system.stateVersion = "25.05";

    imports = [
      "${inputs.nixos-hardware}/common/cpu/intel/alder-lake/default.nix"
      inputs.nixos-hardware.nixosModules.common-pc-ssd
    ];

    networking.firewall.enable = false;

    services.openssh.enable = true;
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
