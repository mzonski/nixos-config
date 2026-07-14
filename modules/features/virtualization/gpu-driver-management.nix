{ delib, pkgs, ... }:
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
          ExecStartPre = "${pkgs.systemd}/bin/systemctl stop my-pc-rgb";
          ExecStart = "${gpu-to-vfio}/bin/gpu-to-vfio";
          ExecStartPost = "${pkgs.systemd}/bin/systemctl start my-pc-rgb";
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
          ExecStartPre = "${pkgs.systemd}/bin/systemctl stop my-pc-rgb";
          ExecStart = "${gpu-to-nvidia}/bin/gpu-to-nvidia";
          ExecStartPost = "${pkgs.systemd}/bin/systemctl start my-pc-rgb";
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
