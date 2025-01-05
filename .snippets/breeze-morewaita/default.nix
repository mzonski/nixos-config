# as I still don't know how to set KDE icon theme thru qt5ct/qt6ct/kvantum I'll just create icons with default icon pack name :)
{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  gtk3,
  xdg-utils,
  ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "morewaita-icon-theme";
  version = "47.2";

  src = fetchFromGitHub {
    owner = "somepaulo";
    repo = "MoreWaita";
    rev = "refs/tags/v${version}";
    hash = "sha256-LvkYLY8PYajCb1x1p0HfpKoMq+t4XwH/w9Hvy9YXzk0=";
  };

  nativeBuildInputs = [
    gtk3
    xdg-utils
  ];

  installPhase = ''
    runHook preInstall

    install -d $out/share/icons/breeze
    cp -r . $out/share/icons/breeze
    gtk-update-icon-cache -f -t $out/share/icons/breeze && xdg-desktop-menu forceupdate

    runHook postInstall
  '';

  meta = with lib; {
    description = "Adwaita style extra icons theme for Gnome Shell";
    homepage = "https://github.com/somepaulo/MoreWaita";
    license = with licenses; [ gpl3Only ];
    platforms = platforms.linux;
    maintainers = with maintainers; [ pkosel ];
  };
}
