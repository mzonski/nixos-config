{
  config,
  delib,
  pkgs,
  ...
}:

let
  inherit (delib) module boolOption strOption;
in
module {
  name = "features.windows-data-partition";

  options.features.windows-data-partition = {
    enable = boolOption false;
    diskUuid = strOption "";
  };

  nixos.ifEnabled =
    { cfg, ... }:
    {
      boot.blacklistedKernelModules = [
        "ntfs3"
      ];

      environment.systemPackages = with pkgs; [
        ntfs3g
      ];

      fileSystems."/mnt/data" = {
        device = "/dev/disk/by-uuid/${cfg.diskUuid}";
        fsType = "ntfs-3g";
        options = [
          "uid=1000"
          "gid=988"
          "fmask=0000"
          "dmask=0000"
          "umask=0000"
          "windows_names"
          "discard"
          "noatime"
          "nofail"
          "comment=x-gvfs-show"
        ];
      };
    };
}
