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
    vlc
    ;

  SCALE_FACTOR = "1.6"; # TODO: SCALE sync

  vlcWrapper = writeShellScript "vlc-wrapper" ''
    env QT_SCALE_FACTOR=${SCALE_FACTOR} ${pkgs.vlc}/bin/vlc "$@"
  '';
  desktopEntry = writeTextFile {
    name = "vlc-desktop";
    destination = "/share/applications/vlc.desktop";
    text = builtins.readFile (
      runCommand "vlc.desktop" { } ''
        sed 's|Exec=/nix/store/.*/bin/vlc|Exec=${vlcWrapper}|' \
          ${vlc}/share/applications/vlc.desktop > $out
      ''
    );
  };

  patchedPackage = (
    symlinkJoin {
      name = "vlc";
      paths = [
        desktopEntry
        vlc
      ];
      buildInputs = [ makeBinaryWrapper ];
      postBuild = "wrapProgram $out/bin/vlc --set QT_SCALE_FACTOR ${SCALE_FACTOR}";
    }
  );
in
module {
  name = "programs.desktop.vlc";
  options = singleEnableOption host.isDesktop;
  home.ifEnabled.home.packages = [ patchedPackage ];
}
