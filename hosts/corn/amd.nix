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
      inputs.nixos-extra.nixosHardware.modules.common-cpu-amd
      inputs.nixos-extra.nixosHardware.modules.common-cpu-amd-raphael-igpu
    ];

    environment.systemPackages = with pkgs; [
      amdgpu_top
    ];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    hardware.amdgpu.initrd.enable = true;
  };
}
