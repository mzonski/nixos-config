{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
  ...
}:

stdenv.mkDerivation {
  name = "asus-ec-sensors";
  version = "0.1.0-custom";

  src = fetchFromGitHub {
    owner = "zeule";
    repo = "asus-ec-sensors";
    rev = "de633c4061f38baffa0c706e9d034ead5c8c20d8";
    sha256 = "sha256-Fwn4DIrOPBjGthehyeDeAAfXcf6GMxxNM+2Hchabirw=";
  };

  hardeningDisable = [ "pic" ];

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}"
  ];

  installPhase = ''
    install asus-ec-sensors.ko -Dm444 -t ${placeholder "out"}/lib/modules/${kernel.modDirVersion}/kernel/drivers/hwmon
  '';

  meta = with lib; {
    description = "Linux HWMON sensors driver for ASUS motherboards to read sensor data from the embedded controller";
    homepage = "https://github.com/zeule/asus-ec-sensors";
    license = licenses.gpl2Only;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ nickhu ];
    broken = kernel.kernelOlder "5.11";
  };
}
