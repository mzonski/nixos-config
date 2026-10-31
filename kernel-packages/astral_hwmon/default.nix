{
  lib,
  kernel,
  fetchFromGitHub,
  ...
}:
let
  # keep in sync with packages/astral-guard
  version = "0.3.1";
  isClang = kernel.stdenv.cc.isClang or false;
in
kernel.stdenv.mkDerivation {
  name = "astral_hwmon";
  version = version;

  src = fetchFromGitHub {
    owner = "ksokolowski";
    repo = "astral-hwmon";
    tag = "v${version}";
    sha256 = "sha256-4KIHezXsu0Q9XCl1sGcY457s2w0UpruhFref1N/ukyE=";
  };

  hardeningDisable = [ "pic" ];

  nativeBuildInputs = kernel.moduleBuildDependencies;

  buildFlags = [ "module" ];

  makeFlags = [
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ]
  ++ lib.optionals isClang [
    "LLVM=1"
    "CC=clang"
  ];

  installPhase = ''
    install driver/astral-hwmon.ko -Dm444 -t $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/hwmon
  '';

  meta = with lib; {
    description = "Per-pin 12VHPWR monitoring for ASUS ROG Astral cards (${version})";
    homepage = "https://github.com/ksokolowski/astral-hwmon";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
  };
}
