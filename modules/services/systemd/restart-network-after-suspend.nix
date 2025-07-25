{ delib, pkgs, ... }:

let
  inherit (delib) module boolOption strOption;
in
module {
  name = "services.systemd.restart-network-after-suspend";

  options.services.systemd.restart-network-after-suspend = {
    enable = boolOption false;
    networkInterface = strOption "enp113s0";
  };

  nixos.ifEnabled =
    { cfg, ... }:
    {
      systemd.services.restart-network-after-suspend = {
        description = "Restart network interface after suspend";
        wantedBy = [
          "systemd-suspend.service"
          "systemd-hibernate.service"
        ];
        after = [
          "systemd-suspend.service"
          "systemd-hibernate.service"
        ];

        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.systemd}/bin/systemctl restart systemd-networkd";
          ExecStartPost = [
            "${pkgs.iproute2}/bin/ip link set ${cfg.networkInterface} down"
            "${pkgs.bash}/bin/bash -c 'sleep 2'"
            "${pkgs.iproute2}/bin/ip link set ${cfg.networkInterface} up"
          ];
          RemainAfterExit = false;
        };
      };
    };
}
