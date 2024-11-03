{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  gnome-themes-extra,
  gtk-engine-murrine,
  jdupes,
  sassc,
}:

stdenvNoCC.mkDerivation rec {
  pname = "collopuccisharp-gtk-theme";
  version = "unstable-2024-11-03";

  src = fetchFromGitHub {
    owner = "mzonski";
    repo = "colloid-sharp-gtk-theme";
    rev = "e8dd006209dc0d29e67f0799279e3e249fd4f016";
    #hash = lib.fakeHash;
    hash = "sha256-knHM5blJFRR9QokTeomos+AWUEUfHwkZIhukPWHFFao=";
  };

  nativeBuildInputs = [
    jdupes
    sassc
  ];

  buildInputs = [
    gnome-themes-extra
  ];

  propagatedUserEnvPkgs = [
    gtk-engine-murrine
  ];

  postPatch = ''
    patchShebangs install.sh
  '';

  installPhase = ''
    runHook preInstall

    ./install.sh --name Collopuccisharp --theme purple --color dark --size compact  \
      --tweaks catppuccin rimless normal black \
      --dest $out/share/themes

    jdupes --quiet --link-soft --recurse $out/share

    runHook postInstall
  '';

  meta = with lib; {
    description = "Colloid theme on catpuccin flavour with sharp corners";
    homepage = "https://github.com/mzonski/colloid-sharp-gtk-theme";
    license = licenses.gpl3Only;
    platforms = platforms.unix;
    maintainers = [ maintainers.romildo ];
  };
}
