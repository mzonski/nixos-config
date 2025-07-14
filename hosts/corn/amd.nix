{
  delib,
  inputs,
  pkgs,
  ...
}:

delib.host {
  name = "corn";

  myconfig.user.groups = [ "video" ];

  nixos = {
    imports = [
      inputs.nixos-hardware.nixosModules.common-cpu-amd
      inputs.nixos-hardware.nixosModules.common-cpu-amd-raphael-igpu
    ];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;

      extraPackages = [
        pkgs.amdvlk
      ];

      extraPackages32 = [
        pkgs.driversi686Linux.amdvlk
      ];
    };
  };
}
