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

    environment.systemPackages = with pkgs; [
      amdgpu_top
    ];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    hardware.amdgpu = {
      amdvlk.enable = true;
      amdvlk.support32Bit.enable = true;
      initrd.enable = true;
    };
  };
}
