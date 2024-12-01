{
  lib,
  fetchFromGitHub,
  python3Packages,
  gtk3,
  gtk-layer-shell,
  wl-clipboard,
  cliphist,
  xdg-utils,
  wrapGAppsHook3,
  gobject-introspection,
  ...
}:

python3Packages.buildPythonApplication rec {
  pname = "nwg-clipman";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "nwg-piotr";
    repo = "nwg-clipman";
    rev = "78d45e5b5093711e0e692f8ecf9af207417eb791";
    hash = "sha256-bAE9E6P+qfKrfRxb134k4r7DtIWGB+4JdiXKpI7gJ5M="; # Replace with actual hash after first build attempt
  };

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    gtk-layer-shell
  ];

  propagatedBuildInputs = [
    python3Packages.pygobject3
    wl-clipboard
    cliphist
    xdg-utils
  ];

  dontWrapGApps = true;

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}");
  '';

  # Upstream has no tests
  doCheck = false;

  meta = with lib; {
    description = "GTK3-based GUI for cliphist clipboard manager";
    homepage = "https://github.com/nwg-piotr/nwg-clipman";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = [ ];
    mainProgram = "nwg-clipman";
  };
}
