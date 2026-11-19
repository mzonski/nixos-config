{
  delib,
  host,
  pkgs,
  ...
}:
delib.module {
  name = "appimage";

  options = delib.singleEnableOption host.isDesktop;

  nixos.ifEnabled =
    let
      mountOptions = [
        "ro"
        "x-gvfs-hide"
        "resolve-symlinks"
      ];
    in
    {
      programs.appimage.enable = true;
      programs.appimage.binfmt = true;

      fonts.fontDir.enable = true;

      system.fsPackages = [ pkgs.bindfs ];

      fileSystems."/usr/share/fonts" = {
        device = "/run/current-system/sw/share/X11/fonts";
        fsType = "fuse.bindfs";
        options = mountOptions;
      };

      fileSystems."/usr/share/icons" = {
        device = "/run/current-system/sw/share/icons";
        fsType = "fuse.bindfs";
        options = mountOptions;
      };

      fileSystems."/usr/share/themes" = {
        device = "/run/current-system/sw/share/themes";
        fsType = "fuse.bindfs";
        options = mountOptions;
      };
    };
}
