{ pkgs, stdenv, fetchurl, lib, ... }:
stdenv.mkDerivation rec {
  pname = "apple-fonts";
  version = "1";

  pro = fetchurl {
    url = "https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg";
    sha256 = "sha256-Mu0pmx3OWiKBmMEYLNg+u2MxFERK07BQGe3WAhEec5Q=";
  };

  compact = fetchurl {
    url = "https://devimages-cdn.apple.com/design/resources/download/SF-Compact.dmg";
    sha256 = "sha256-Mkf+GK4iuUhZdUdzMW0VUOmXcXcISejhMeZVm0uaRwY=";
  };

  mono = fetchurl {
    url = "https://devimages-cdn.apple.com/design/resources/download/SF-Mono.dmg";
    sha256 = "sha256-tZHV6g427zqYzrNf3wCwiCh5Vjo8PAai9uEvayYPsjM=";
  };

  ny = fetchurl {
    url = "https://devimages-cdn.apple.com/design/resources/download/NY.dmg";
    sha256 = "sha256-tn1QLCSjgo5q4PwE/we80pJavr3nHVgFWrZ8cp29qBk=";
  };

  nativeBuildInputs = [ pkgs.p7zip pkgs.nerd-font-patcher ];

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
