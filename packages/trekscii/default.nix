{
  lib,
  stdenv,
  fetchFromGitHub,
  ...
}:
let
  pname = "trekscii";
in
stdenv.mkDerivation {
  inherit pname;
  version = "unstable";

  src = fetchFromGitHub {
    owner = "Misterio77";
    repo = "trekscii";
    rev = "c56f087e527e2170e747d6ae033fc182973bfb28";
    hash = "sha256-MJZFESpSF4Ogqe5E2tC4cH6FJzsRUy5Zu8/WY2eEDEg=";
  };

  installPhase = ''
    install -Dm 0755 bin/trekscii $out/bin/trekscii
  '';

  meta = with lib; {
    platforms = platforms.all;
  };
}
