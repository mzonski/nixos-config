{
  pkgs,
  stdenv,
  fetchurl,
  lib,
  ...
}:
stdenv.mkDerivation rec {
  pname = "apple-fonts";
  version = "1.5";

  pro = fetchurl {
    url = "https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg";
    sha256 = "sha256-W0sZkipBtrduInk0oocbFAXX1qy0Z+yk2xUyFfDWx4s=";
  };

  compact = fetchurl {
    url = "https://devimages-cdn.apple.com/design/resources/download/SF-Compact.dmg";
    sha256 = "sha256-RWeq4GFt01r8NLrWvvVH5y/R5lhFMFozlzBkUY0dU0g=";
  };

  mono = fetchurl {
    url = "https://devimages-cdn.apple.com/design/resources/download/SF-Mono.dmg";
    sha256 = "sha256-bUoLeOOqzQb5E/ZCzq0cfbSvNO1IhW1xcaLgtV2aeUU=";
  };

  ny = fetchurl {
    url = "https://devimages-cdn.apple.com/design/resources/download/NY.dmg";
    sha256 = "sha256-HC7ttFJswPMm+Lfql49aQzdWR2osjFYHJTdgjtuI+PQ=";
  };

  nativeBuildInputs = [
    pkgs.p7zip
    pkgs.nerd-font-patcher
  ];

  sourceRoot = ".";

  dontUnpack = true;

  buildPhase = ''
    7z x ${pro}
    cd SFProFonts
    7z x 'SF Pro Fonts.pkg'
    7z x 'Payload~'
    mkdir -p $out/fontfiles
    mv Library/Fonts/* $out/fontfiles
    cd ..
    7z x ${mono}
    cd SFMonoFonts
    7z x 'SF Mono Fonts.pkg'
    7z x 'Payload~'
    mv Library/Fonts/* $out/fontfiles
    cd ..
    7z x ${compact}
    cd SFCompactFonts
    7z x 'SF Compact Fonts.pkg'
    7z x 'Payload~'
    mv Library/Fonts/* $out/fontfiles
    cd ..
    7z x ${ny}
    cd NYFonts
    7z x 'NY Fonts.pkg'
    7z x 'Payload~'
    mv Library/Fonts/* $out/fontfiles

    for f in $out/fontfiles/SF-Mono-*; do
     nerd-font-patcher $f --mono --quiet --fontawesome --octicons --pomicons --codicons --powerline --out $out/fontfiles
    done
  '';

  installPhase = ''
    mkdir -p $out/share/fonts/opentype $out/share/fonts/truetype
    mv $out/fontfiles/*.otf $out/share/fonts/opentype
    mv $out/fontfiles/*.ttf $out/share/fonts/truetype
    rm -rf $out/fontfiles
  '';

  meta = {
    description = "Apple San Francisco, New York fonts";
    homepage = "https://developer.apple.com/fonts/";
    license = lib.licenses.unfree;
  };
}
