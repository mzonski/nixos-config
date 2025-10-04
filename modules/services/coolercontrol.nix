{
  delib,
  host,
  pkgs,
  homeManagerUser,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (delib)
    module
    moduleOptions
    boolOption
    strOption
    ;
in
module {
  name = "services.coolercontrol";

  options = moduleOptions {
    enable = boolOption host.isDesktop;
    adminUser = strOption "CCAdmin";
    adminPassword = strOption "coolAdmin";
    cookiesFile = strOption "/home/${homeManagerUser}/.local/share/org.coolercontrol.CoolerControl/cookies.txt";
    apiUrl = strOption "http://localhost:11987";
    revertToProfileOnShutdown = {
      enable = boolOption true;
      targetModeId = strOption "e7de53fd-c644-4959-b299-8ad13a92be23";
    };
  };

  nixos.ifEnabled =
    { cfg, ... }:
    let
      inherit (import ../../lib/bash/utils.nix { inherit lib; }) extendPath;
    in
    {
      programs.coolercontrol.enable = true;
      programs.coolercontrol.nvidiaSupport = true;

      systemd.services.coolercontrold = {
        serviceConfig = {
          ExecStart = [
            ""
            "${pkgs.coolercontrol.coolercontrold}/bin/coolercontrold --nvidia-cli"
          ];
          ExecStop = mkIf cfg.revertToProfileOnShutdown.enable [
            (pkgs.writeShellScript "coolercontrol-shutdown" ''
              ${extendPath ([
                pkgs.curl
                pkgs.systemd
              ])}

              curl -X POST "${cfg.apiUrl}/login" -u "${cfg.adminUser}:${cfg.adminPassword}" -c ${cfg.cookiesFile}
              curl -X POST "${cfg.apiUrl}/modes-active/${cfg.revertToProfileOnShutdown.targetModeId}" -b ${cfg.cookiesFile}

              systemctl kill --signal=TERM coolercontrold.service
            '')
          ];
        };
      };
    };
}
