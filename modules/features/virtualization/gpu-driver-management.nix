{ delib, ... }:

let
  inherit (delib) module;
in
module {
  name = "features.virt-manager.vfio-passtrough";

  nixos.ifEnabled =
    { cfg, ... }:
    let
      inherit (cfg.scripts) gpu-status gpu-to-vfio gpu-to-nvidia;
    in
    {
      systemd.services.gpu-to-vfio = {
        description = "Switch GPU driver to VFIO";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${gpu-to-vfio}/bin/gpu-to-vfio";
          User = "root";
          RemainAfterExit = false;
        };
        wantedBy = [ ];
        restartIfChanged = false;
      };

      systemd.services.gpu-to-nvidia = {
        description = "Switch GPU driver to NVIDIA";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${gpu-to-nvidia}/bin/gpu-to-nvidia";
          User = "root";
          RemainAfterExit = false;
        };
        wantedBy = [ ];
        restartIfChanged = false;
      };

      environment.systemPackages = [
        gpu-status
        gpu-to-vfio
        gpu-to-nvidia
      ];
    };
}
