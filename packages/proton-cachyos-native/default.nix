{
  stdenv,
  fetchurl,
  zstd,
  ...
}:
stdenv.mkDerivation rec {
  baseVersion = "11.0";
  releaseVersion = "20260703";
  hashVersion = "sha256-OpdzM7IxE+7qJayJc1daCGjLtgH2otHys88BBYsYW3g=";

  name = "proton-cachyos-native";
  version = "${baseVersion}-${releaseVersion}";

  src = fetchurl {
    url = "https://mirror.cachyos.org/repo/x86_64/cachyos/${name}-1:${baseVersion}.${releaseVersion}-1-x86_64.pkg.tar.zst";
    hash = hashVersion;
  };

  nativeBuildInputs = [ zstd ];

  installPhase = ''
    tar -I zstd -xf $src
    mkdir -p $out/share/steam/compatibilitytools.d
    mv usr/share/steam/compatibilitytools.d/${name} $out/share/steam/compatibilitytools.d/
  '';
}
