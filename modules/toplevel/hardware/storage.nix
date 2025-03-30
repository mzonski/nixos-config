{
  delib,
  lib,
  inputs,
  ...
}:

let
  inherit (builtins) head;
  inherit (lib) mkIf mkMerge;
  inherit (delib)
    module
    boolOption
    listOfOption
    strOption
    str
    ;

  ESP = {
    priority = 1;
    name = "boot";
    start = "1M";
    end = "2048M";
    type = "EF00";
    content = {
      type = "filesystem";
      format = "vfat";
      mountpoint = "/boot";
      mountOptions = [
        "fmask=0022"
        "dmask=0022"
        "iocharset=utf8"
      ];
    };
  };
in
module {
  name = "hardware.storage";

  options.hardware.storage = {
    enable = boolOption false;
    layout = strOption "desktop_ext4";
    devices = listOfOption str [ ];
    swapSize = strOption "32G";
  };

  nixos.always.imports = [ inputs.disko.nixosModules.disko ];

  nixos.ifEnabled =
    { cfg, ... }:
    {
      disko.devices = mkMerge [
        (mkIf (cfg.layout == "single_ext4") {
          disk.main = {
            device = head cfg.devices;
            type = "disk";
            content = {
              type = "gpt";
              partitions = {
                inherit ESP;
                root = {
                  end = "-" + cfg.swapSize;
                  content = {
                    type = "filesystem";
                    format = "ext4";
                    mountpoint = "/";
                  };
                };
                swap = {
                  size = cfg.swapSize;
                  content = {
                    type = "swap";
                    discardPolicy = "both";
                    resumeDevice = true;
                  };
                };
              };
            };
          };
        })
        (mkIf (cfg.layout == "desktop_btrfs_single_disk") {
          disk.main = {
            type = "disk";
            device = head cfg.devices;
            content = {
              type = "gpt";
              partitions = {
                inherit ESP;
                nixos = {
                  name = "nixos";
                  size = "100%";
                  content = {
                    type = "btrfs";
                    extraArgs = [ "-f" ];
                    subvolumes = {
                      "/root" = {
                        mountpoint = "/";
                        mountOptions = [
                          "compress=zstd"
                          "noatime"
                        ];
                      };
                      "/home" = {
                        mountpoint = "/home";
                        mountOptions = [
                          "compress=zstd"
                          "noatime"
                        ];
                      };
                      "/nix" = {
                        mountpoint = "/nix";
                        mountOptions = [
                          "compress=zstd"
                          "noatime"
                        ];
                      };
                      "/swap" = {
                        mountpoint = "/.swapvol";
                        swap.swapfile.size = "20M";
                      };
                    };
                  };
                };
                # swap = {
                #   size = "100%";
                #   content = {
                #     type = "swap";
                #     discardPolicy = "both";
                #     resumeDevice = true;
                #   };
                # };
              };
            };
          };
        })
      ];
    };
}
