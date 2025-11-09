{
  delib,
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (delib)
    module
    moduleOptions
    boolOption
    strOption
    intOption
    listOfOption
    submodule
    allowNull
    pathOption
    ;
  inherit (pkgs) writeShellScript;
in
module {
  name = "features.zfs";

  options = moduleOptions {
    enable = boolOption false;
    ssd = boolOption false;
    snapshots = boolOption false;
    scrub = boolOption false;
    hostId = strOption "";
    pools = listOfOption (lib.types.str) [ ];
    arc = {
      min = intOption 1;
      max = intOption 4;
    };
    encryptedDatasets = listOfOption (submodule {
      options = {
        dataset = strOption "";
        passwordSopsKey = strOption "";
        sopsFile = allowNull (pathOption null);
      };
    }) [ ];
  };

  nixos.ifEnabled =
    { cfg, ... }:
    {
      assertions = [
        {
          assertion = cfg.hostId != "";
          message = "features.zfs.hostId must not be empty";
        }
        {
          assertion = cfg.pools != [ ] || !cfg.scrub;
          message = "features.zfs.pools must be specified when scrub is enabled";
        }
      ];

      networking.hostId = cfg.hostId;

      boot.kernelPackages =
        let
          zfsCompatibleKernelPackages = lib.filterAttrs (
            name: kernelPackages:
            (builtins.match "linux_[0-9]+_[0-9]+" name) != null
            && (builtins.tryEval kernelPackages).success
            && (!kernelPackages.${config.boot.zfs.package.kernelModuleAttribute}.meta.broken)
          ) pkgs.linuxKernel.packages;
          latestKernelPackage = lib.last (
            lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
              builtins.attrValues zfsCompatibleKernelPackages
            )
          );
        in
        latestKernelPackage;

      boot.kernelParams =
        let
          GB = 1024 * 1024 * 1024;
        in
        [
          "zfs.zfs_arc_max=${toString (cfg.arc.max * GB)}"
          "zfs.zfs_arc_min=${toString (cfg.arc.min * GB)}"
        ];

      boot.supportedFilesystems = {
        zfs = true;
      };

      boot.zfs = {
        forceImportRoot = false;
        forceImportAll = false;
        allowHibernation = false;

        extraPools = cfg.pools;
        requestEncryptionCredentials = false;
      };

      sops.secrets = lib.mkMerge (
        lib.forEach cfg.encryptedDatasets (dataset: {
          ${dataset.passwordSopsKey} = {
            sopsFile = dataset.sopsFile;
            mode = "0400";
            owner = "root";
            group = "root";
          };
        })
      );

      systemd.services = lib.mkMerge (
        lib.forEach cfg.encryptedDatasets (
          { dataset, passwordSopsKey, ... }:
          let
            serviceName = "zfs-load-key-${lib.toLower (lib.replaceStrings [ "/" ] [ "-" ] dataset)}";
            sopsKeyPath = config.sops.secrets.${passwordSopsKey}.path;
          in
          {
            ${serviceName} = {
              description = "Load ZFS encryption key for ${dataset}";
              requires = [
                "run-secrets.d.mount"
                "zfs-import.target"
              ];

              wantedBy = [ "multi-user.target" ];

              serviceConfig = {
                Type = "oneshot";
                ExecStart = "${writeShellScript (serviceName) ''
                  if ${pkgs.zfs}/bin/zfs get -H -o value keystatus ${dataset} | grep -wq "available"; then
                    echo "Encryption key already loaded for ${dataset}"
                    exit 0
                  fi

                  if [ -f "${sopsKeyPath}" ]; then
                    cat "${sopsKeyPath}" | ${pkgs.zfs}/bin/zfs load-key ${dataset}
                    ${pkgs.zfs}/bin/zfs mount ${dataset}

                    echo "Successfully loaded key and mounted ${dataset}"
                  else
                    echo "Error: SOPS secret file not found"
                    exit 1
                  fi
                ''}";
              };
            };

          }
        )
      );

      services.zfs = {
        autoScrub = {
          enable = cfg.scrub;
          interval = "Sun *-*-* 02:00:00";
          inherit (cfg) pools;
        };

        trim = {
          enable = cfg.ssd;
          interval = "weekly";
        };

        autoSnapshot = {
          enable = cfg.snapshots;
          frequent = 0;
          hourly = 0;
          daily = 7;
          weekly = 4;
          monthly = 6;
        };

        zed = {
          enableMail = false;
        };
      };
    };
}
