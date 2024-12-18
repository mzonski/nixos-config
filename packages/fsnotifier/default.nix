{
  lib,
  stdenv,
  fetchFromGitHub,
  ...
}:

stdenv.mkDerivation rec {
  version = "2024.3.1";
  pname = "fsnotifier";

  src = fetchFromGitHub {
    owner = "JetBrains";
    repo = "intellij-community";
    rev = "e58ff5365871044b0c0f5aab18531c734739234b";
    hash = "sha256-LBrrfmsVlYB/LZeAtFahLgzihhy7cuJ6bdQQbgoCW78=";
    sparseCheckout = [ "native/fsNotifier/linux" ];
  };

  # fix for hard-links in nix-store, https://github.com/JetBrains/intellij-community/pull/2171
  patches = [ ./fsnotifier.patch ];

  sourceRoot = "${src.name}/native/fsNotifier/linux";

  buildPhase = ''
    mkdir -p $out/bin

    $CC -O2 -Wall -Wextra -Wpedantic -D "VERSION=\"${version}\"" -std=c11 main.c inotify.c util.c -o fsnotifier

    cp fsnotifier $out/bin/fsnotifier
  '';

  meta = {
    homepage = "https://github.com/JetBrains/intellij-community/tree/master/native/fsNotifier/linux";
    description = "IntelliJ Platform companion program for watching and reporting file and directory structure modification";
    license = lib.licenses.asl20;
    mainProgram = "fsnotifier";
    maintainers = with lib.maintainers; [ shyim ];
    platforms = lib.platforms.linux;
  };
}
