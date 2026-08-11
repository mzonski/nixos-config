{
  stdenv,
  fetchurl,
  zstd,
  ...
}:
stdenv.mkDerivation rec {
  baseVersion = "11.0";
  releaseVersion = "20260703";
  hashVersion = "sha256-J2JsL9N0wsCFfD/ycazQznxdbDex5lGgYbgddJXc8VA=";

  name = "proton-cachyos-native";
  version = "${baseVersion}-${releaseVersion}";

  src = fetchurl {
    url = "https://mirror.cachyos.org/repo/x86_64/cachyos/${name}-1:${baseVersion}.${releaseVersion}-2-x86_64.pkg.tar.zst";
    hash = hashVersion;
  };

  nativeBuildInputs = [ zstd ];

  installPhase = ''
    tar -I zstd -xf $src
    mkdir -p $out/share/steam/compatibilitytools.d
    mv usr/share/steam/compatibilitytools.d/${name} $out/share/steam/compatibilitytools.d/
  '';
}
