{
  delib,
  pkgs,
  host,
  ...
}:
let
  inherit (delib) module singleEnableOption;
  inherit (builtins)
    listToAttrs
    map
    concatLists
    attrValues
    ;
in
module {
  name = "programs.desktop.peazip";

  options = singleEnableOption host.isDesktop;

  home.ifEnabled = (
    let
      _7zz = (
        pkgs._7zz.override {
          enableUnfree = true;
        }
      );

      peazip = (
        pkgs.local.peazip-gtk2.override {
          _7zz = _7zz;
        }
      );

      hiddenDesktopEntries = listToAttrs (
        map
          (name: {
            name = name;
            value = {
              name = name;
              noDisplay = true;
            };
          })
          [
            "peazip-add-to-archive"
            "peazip-add-to-brotli"
            "peazip-add-to-bzip2"
            "peazip-add-to-gzip"
            "peazip-add-to-pea"
            "peazip-add-to-wim"
            "peazip-add-to-xz"
            "peazip-add-to-zpaq"
            "peazip-add-to-zstd"
            "peazip-convert"
            "peazip-extract-desktop"
            "peazip-extract-documents"
            "peazip-extract-downloads"
          ]
      );

      archiveFormats = {
        "7z" = [ "application/x-7z-compressed" ];
        "arc" = [ "application/x-arc" ];
        "brotli" = [ "application/x-brotli" ];
        "bzip2" = [
          "application/x-bzip2"
          "application/x-bzip"
        ];
        "gzip" = [
          "application/gzip"
          "application/x-gzip"
        ];
        "pea" = [ "application/x-pea" ];
        "tar" = [
          "application/x-tar"
          "application/x-gtar"
          "application/x-ustar"
          "application/x-compressed-tar"
          "application/x-bzip-compressed-tar"
          "application/x-xz-compressed-tar"
          "application/x-lzma-compressed-tar"
        ];
        "upx" = [ "application/x-upx" ];
        "wim" = [ "application/x-wim" ];
        "xz" = [ "application/x-xz" ];
        "zip" = [
          "application/zip"
          "application/x-zip"
          "application/x-zip-compressed"
        ];
        "zstd" = [
          "application/zstd"
          "application/x-zstd"
        ];

        "rar" = [
          "application/x-rar"
          "application/x-rar-compressed"
          "application/vnd.rar"
        ];

        "ace" = [ "application/x-ace" ];
        "arj" = [ "application/x-arj" ];
        "lha" = [
          "application/x-lha"
          "application/x-lzh"
        ];
        "lzma" = [ "application/x-lzma" ];
      };

      allMimeTypes = concatLists (attrValues archiveFormats);

      selectionMimeTypes = [
        "inode/directory"
        "application/x-directory"
      ];

      allArchiveMimeTypes = concatLists (attrValues archiveFormats);

      createDefaultApps =
        mimeTypes: app:
        listToAttrs (
          map (mimeType: {
            name = mimeType;
            value = app;
          }) mimeTypes
        );

      createAssociations =
        mimeTypes: apps:
        listToAttrs (
          map (mimeType: {
            name = mimeType;
            value = apps;
          }) mimeTypes
        );

      archiveExtractionApps = [
        "peazip.desktop"
        "peazip-extract-here.desktop"
        "peazip-extract-smart.desktop"
      ];

      compressionApps = [
        "peazip.desktop"
      ];

    in
    {
      home.packages = [
        peazip
        _7zz
      ];

      xdg = {
        desktopEntries = hiddenDesktopEntries;

        mimeApps = {
          enable = true;
          defaultApplications = createDefaultApps allMimeTypes "peazip.desktop";
          associations.added =
            (createAssociations allArchiveMimeTypes archiveExtractionApps)
            // (createAssociations selectionMimeTypes compressionApps);
        };
      };
    }
  );
}
