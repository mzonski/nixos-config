{
  lib,
  stdenv,
  fetchFromGitHub,
  ...
}:
let
  # keep in sync with kernel-packages/astral_hwmon
  version = "0.3.1";
in
stdenv.mkDerivation {
  pname = "astral-guard";
  inherit version;

  src = fetchFromGitHub {
    owner = "ksokolowski";
    repo = "astral-hwmon";
    tag = "v${version}";
    hash = "sha256-4KIHezXsu0Q9XCl1sGcY457s2w0UpruhFref1N/ukyE=";
  };

  buildFlags = [ "guard" ];
  installTargets = [ "install-guard" ];
  installFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = with lib; {
    description = "12VHPWR connector checks over the astral-hwmon sysfs sensors";
    homepage = "https://github.com/ksokolowski/astral-hwmon";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
    mainProgram = "astral-guard";
  };
}
