{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
  ...
}:

stdenv.mkDerivation rec {
  name = "it87-custom";
  version = "unstable-2025-10-06";

  # Original is no longer maintained.
  # This is the same upstream as the AUR uses.
  src = fetchFromGitHub {
    owner = "frankcrawford";
    repo = "it87";
    rev = "60d9def80d65e7e34a73e6f32d8677ad5bfa58a9";
    hash = "sha256-xlUyq1DQFBCvAs9DP6i1ose+6e+nmmXFRyuzRXCg+Ko=";
  };

  hardeningDisable = [ "pic" ];

  nativeBuildInputs = kernel.moduleBuildDependencies;

  preConfigure = ''
    sed -i 's|depmod|#depmod|' Makefile
  '';

  makeFlags = [
    "TARGET=${kernel.modDirVersion}"
    "KERNEL_MODULES=${kernel.dev}/lib/modules/${kernel.modDirVersion}"
    "MODDESTDIR=$(out)/lib/modules/${kernel.modDirVersion}/kernel/drivers/hwmon"
  ];
}
