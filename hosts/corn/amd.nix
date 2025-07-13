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
      inputs.nixos-hardware.nixosModules.common-gpu-amd
      inputs.nixos-hardware.nixosModules.common-cpu-amd
    ];

    environment.systemPackages = with pkgs; [
      amdvlk
    ];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;

      extraPackages32 = [
        pkgs.driversi686Linux.amdvlk
      ];
    };
  };
}
