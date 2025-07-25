{
  delib,
  pkgs,
  host,
  ...
}:
let
  inherit (delib) module singleEnableOption;
  inherit (pkgs)
    writeShellScript
    writeTextFile
    runCommand
    symlinkJoin
    makeBinaryWrapper
    gparted
    ;

  wrapper = writeShellScript "gparted-wrapper" ''
    sudo -E ${gparted}/bin/gparted "$@"
  '';
  desktopEntry = writeTextFile {
    name = "vlc-desktop";
    destination = "/share/applications/gparted.desktop";
    text = builtins.readFile (
      runCommand "gparted.desktop" { } ''
        sed 's|Exec=/nix/store/.*/bin/gparted|Exec=${wrapper}|' \
          ${gparted}/share/applications/gparted.desktop > $out
      ''
    );
  };

  patchedPackage = (
    symlinkJoin {
      name = "gparted";
      paths = [
        desktopEntry
        gparted
      ];
      buildInputs = [ makeBinaryWrapper ];
    }
  );
in
module {
  name = "programs.desktop.gparted";
  options = singleEnableOption host.isDesktop;
  home.ifEnabled.home.packages = [ patchedPackage ];
}
