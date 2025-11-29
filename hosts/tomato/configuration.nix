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
      docker.enable = false;

      zfs = {
        enable = true;
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
          {
            dataset = "HOME/Databases";
            passwordSopsKey = "personal_dataset_password";
            sopsFile = ./secrets.yaml;
          }
        ];
      };
    };

    homelab.enable = true;
    homelab.networking = {
      enable = true;
      defaultVlan = "home";
      defaultOctet = 3;
      vlans = {
        home.macAddress = "00:00:00:00:01:01";
        vpn.macAddress = "00:00:00:00:01:02";
      };
    };

    services = {
      network-share-server = {
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

      coolercontrol.enable = true;
      qbittorrent.enable = true;
      nginx.enable = true;
      grafana.enable = true;
      postgres.enable = true;
      pocket-id.enable = true;
      gitea.enable = true;
      vaultwarden.enable = true;
      tinyauth.enable = true;
      cloudflared.enable = true;
      cloudflared.tunnelId = "768b4452-ed2d-4651-a824-641514e83a62";
      prometheus.enable = true;
      influxdb.enable = true;
    };
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
