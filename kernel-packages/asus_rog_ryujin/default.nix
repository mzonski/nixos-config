{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
  ...
}:
let
  version = "0.1.1-custom";
in
stdenv.mkDerivation {
  name = "asus_rog_ryujin";
  version = version;

  #src = /home/zonni/git/asus_rog_ryujin_iii_extreme-hwmon;
  src = fetchFromGitHub {
    owner = "mzonski";
    repo = "asus_rog_ryujin_iii_extreme-hwmon";
    rev = "99902647cbc0691a9f3d639c44624cc9beab9bc0";
    sha256 = "sha256-ZyDgwcpKL//P8g6FRIqmK2qZcfIiqD2terF8K9C0koU=";
  };

  hardeningDisable = [ "pic" ];

  nativeBuildInputs = kernel.moduleBuildDependencies;

  postPatch = ''
    substituteInPlace Makefile --replace-warn "make W=1 C=1" "make"
    substituteInPlace drivers/hwmon/asus_rog_ryujin.c --replace-warn "MODULE_DESCRIPTION(\"Hwmon driver for Asus ROG Ryujin III EXTREME AIO cooler\");" "MODULE_DESCRIPTION(\"Hwmon driver for Asus ROG Ryujin III EXTREME AIO cooler (${version})\");"
  '';

  makeFlags = [
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
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
