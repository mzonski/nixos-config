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
  secretsFile = ./secrets.yaml;

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
      zfs = {
        enable = true;
        hostId = "d79af5c1";
        pools = [ "HOME" ];
        arc = {
          min = 4;
          max = 12;
        };
        encryptedDatasets = [
          {
            dataset = "HOME/Personal";
            passwordSopsKey = "personal_dataset_password";
            sopsFile = ./secrets.yaml;
          }
        ];
      };
      vnets = {
        enable = true;
        interface.name = "enp3s0";
        vlans = [
          "home"
          "vpn"
        ];
        defaultVlan = "home";
        overrides = {
          home.macAddress = "00:00:00:00:01:01";
        };
      };
    };

    services.coolercontrol.enable = true;

    services.network-share-server = {
      enable = true;
      enableSamba = true;
      enableNfs = true;

      workgroup = "HOMELAB";
      serverString = "Homelab NAS";

      nfsAllowedNetworks = [
        "corn"
      ];

      shares = {
        media = {
          path = "/nas/media";
          type = "public";
          writeList = [
            "@nas-files"
            "@nas-torrents"
            "zonni"
          ];
          nfsExtraConfig = [ "async" ];
        };

        files = {
          path = "/nas/files";
          type = "protected";
          validUsers = [ "zonni" ];
        };

        personal = {
          path = "/nas/personal";
          type = "private";
          validUsers = [ "zonni" ];
          enableNfs = false;
        };

        # backups = {
        #   path = "/nas/backups";
        #   type = "private";
        #   validUsers = [
        #     "zonni"
        #     "backup-user"
        #   ];
        #   sambaExtraConfig = {
        #     "vfs objects" = "recycle";
        #     "recycle:repository" = ".recycle";
        #   };
        # };
      };

      nasGroups = {
        nas-files.gid = 2001;
        nas-torrents.gid = 2002;
      };
    };

    services.qbittorrent.enable = true;
  };

  nixos = {
    nixpkgs.hostPlatform = system;
    system.stateVersion = "25.05";

    imports = [
      "${inputs.nixos-hardware}/common/cpu/intel/alder-lake/default.nix"
      inputs.nixos-hardware.nixosModules.common-pc-ssd
    ];

    networking.firewall.enable = true;
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
