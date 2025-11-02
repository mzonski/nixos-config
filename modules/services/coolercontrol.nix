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
    packageOption
    noDefault
    strOption
    boolOption
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
    setModeOnTerminate = {
      enable = boolOption true;
      targetModeId = strOption "e7de53fd-c644-4959-b299-8ad13a92be23";
    };
    scripts = {
      setModeCpu = {
        targetModeId = strOption "e7de53fd-c644-4959-b299-8ad13a92be23";
        script = noDefault (packageOption null);
      };
      setModeGpu = {
        targetModeId = strOption "5ff2d15b-420f-43c8-8e55-46ca66145d48";
        script = noDefault (packageOption null);
      };
      restartAndSetModeCpu = noDefault (packageOption null);
      restartAndSetModeGpu = noDefault (packageOption null);
      stop = noDefault (packageOption null);
    };
  };

  myconfig.ifEnabled =
    { cfg, ... }:
    let
      curlBin = "${pkgs.curl}/bin/curl";
      mkSetMode =
        targetModeId:
        pkgs.writeShellScript "set-cooler-control-mode-${targetModeId}" ''
          ${curlBin} -sS -X POST "${cfg.apiUrl}/login" -u "${cfg.adminUser}:${cfg.adminPassword}" -c ${cfg.cookiesFile}
          ${curlBin} -sS -X POST "${cfg.apiUrl}/modes-active/${targetModeId}" -b ${cfg.cookiesFile}
        '';
      mkRestartAndSetMode =
        script:
        pkgs.writeShellScript "restart-and-set-mode-${script.targetModeId}" ''
          if ${pkgs.systemd}/bin/systemctl is-active --quiet coolercontrold.service; then
            ${pkgs.systemd}/bin/systemctl restart coolercontrold.service
          else
            ${pkgs.systemd}/bin/systemctl start coolercontrold.service
          fi

          if timeout 30 ${pkgs.bash}/bin/bash -c 'until ${curlBin} -f -s ${cfg.apiUrl} >/dev/null 2>&1; do sleep 1; done'; then
            echo "coolercontrold.service restarted, setting ${script.targetModeId} profile"
            ${script.script}
          else
            echo "coolercontrold.service failed to start"
            exit 1
          fi
        '';
    in
    {
      services.coolercontrol.scripts.setModeCpu.script = mkSetMode cfg.scripts.setModeCpu.targetModeId;
      services.coolercontrol.scripts.setModeGpu.script = mkSetMode cfg.scripts.setModeGpu.targetModeId;
      services.coolercontrol.scripts.restartAndSetModeCpu = mkRestartAndSetMode cfg.scripts.setModeCpu;
      services.coolercontrol.scripts.restartAndSetModeGpu = mkRestartAndSetMode cfg.scripts.setModeGpu;
      services.coolercontrol.scripts.stop = pkgs.writeShellScript "stop-coolercontrold" ''
        ${pkgs.systemd}/bin/systemctl stop coolercontrold.service
        if timeout 30 ${pkgs.bash}/bin/bash -c 'until ! ${pkgs.systemd}/bin/systemctl is-active --quiet coolercontrold.service; do sleep 1; done'; then
          echo "coolercontrold.service stopped successfully"
        else
          echo "Warning: service did not stop within 30 seconds"
          exit 1
        fi
      '';
    };

  nixos.ifEnabled =
    { cfg, ... }:
    {
      programs.coolercontrol.enable = false;
      programs.coolercontrol.nvidiaSupport = false;

      environment.systemPackages = with pkgs.coolercontrol; [
        coolercontrol-gui
      ];

      systemd = {
        packages = with pkgs.coolercontrol; [
          coolercontrold
        ];

        services.coolercontrold = {
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            # ExecStart = [
            #   ""
            #   "${pkgs.coolercontrol.coolercontrold}/bin/coolercontrold --debug"
            # ];
            ExecStop = mkIf cfg.setModeOnTerminate.enable [
              (pkgs.writeShellScript "coolercontrol-shutdown" ''
                ${cfg.scripts.setModeGpu.script}
                ${pkgs.systemd}/bin/systemctl kill --signal=TERM coolercontrold.service
              '')
            ];
            BindReadOnlyPaths = [ "${pkgs.hwdata}/share/hwdata:/usr/share/hwdata" ];
          };
        };
      };
    };
}
