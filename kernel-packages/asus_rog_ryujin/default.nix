{
  lib,
  kernel,
  fetchFromGitHub,
  ...
}:
let
  version = "0.3.0";
  isClang = kernel.stdenv.cc.isClang or false;
in
kernel.stdenv.mkDerivation {
  name = "asus_rog_ryujin";
  version = version;

  #src = /home/zonni/git/asus_rog_ryujin_iii_extreme-hwmon;
  src = fetchFromGitHub {
    owner = "aleksamagicka";
    repo = "asus_rog_ryujin-hwmon";
    rev = "4b9fccb83e8903392226ea8988b4a1c1062a3381";
    sha256 = "sha256-464PlFHSTo/os5LvVIMvFby8tJixeV0FzyNnSDSJrOo=";
  };

  hardeningDisable = [ "pic" ];

  nativeBuildInputs = kernel.moduleBuildDependencies;

  postPatch = ''
    substituteInPlace Makefile --replace-warn "make W=1 C=1" "make"
  '';

  makeFlags = [
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ]
  ++ lib.optionals isClang [
    "LLVM=1"
    "CC=clang"
  ];

  installPhase = ''
    install drivers/hwmon/asus_rog_ryujin.ko -Dm444 -t $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/hwmon
  '';

  meta = with lib; {
    description = "ASUS ROG Ryujin III Extreme hwmon driver (${version})";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
  };
}
