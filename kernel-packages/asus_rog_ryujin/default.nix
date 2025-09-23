{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
  ...
}:

stdenv.mkDerivation {
  name = "asus_rog_ryujin";
  version = "0.1.0-custom";

  src = fetchFromGitHub {
    owner = "mzonski";
    repo = "asus_rog_ryujin_iii_extreme-hwmon";
    rev = "12b489f6bc071859d6fb0df42569d2d68248c6b6";
    sha256 = "sha256-4yHlMDvxnteCbJL5ghKwNb9dSHsRr3wtYz2OWFzMSxg=";
  };

  hardeningDisable = [ "pic" ];

  nativeBuildInputs = kernel.moduleBuildDependencies;

  postPatch = ''
    substituteInPlace Makefile --replace "make W=1 C=1" "make"
  '';

  makeFlags = [
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  installPhase = ''
    install drivers/hwmon/asus_rog_ryujin.ko -Dm444 -t $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/hwmon
  '';

  meta = with lib; {
    description = "ASUS ROG Ryujin III Extreme hwmon driver";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
  };
}
