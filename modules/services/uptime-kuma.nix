{
  delib,
  pkgs,
  lib,
  ...
}:
let
  inherit (delib)
    module
    moduleOptions
    boolOption
    strOption
    intOption
    ;
  serviceName = "uptime-kuma";
in
module {
  name = "services.uptime-kuma";

  options = moduleOptions {
    enable = boolOption false;
    dataDir = strOption "/nas/database/${serviceName}";
    domain = strOption "https://uptime.zonni.pl";
    port = intOption 8088;
  };

  myconfig.ifEnabled =
    { cfg, ... }:
    {
      homelab.reverse-proxy.${serviceName} = {
        port = cfg.port;
        subdomain = "uptime";
        requireAuth = true;
        root = true;
        public = false;
      };
      user.groups = [ serviceName ];
      homelab.users.db = [ serviceName ];
      homelab.users.auth = [ serviceName ];
    };

  nixos.ifEnabled =
    { myconfig, cfg, ... }:
    {
      users.users.${serviceName} = {
        uid = 986;
        isSystemUser = true;
        group = serviceName;
      };
      users.groups.${serviceName}.gid = 981;

      environment.systemPackages = with pkgs; [
        chromium
      ];

      systemd.services.uptime-kuma = {
        after = [ "zfs.target" ];
        requires = [ "zfs.target" ];

        path = [ pkgs.chromium ];

        serviceConfig = {
          User = serviceName;
          Group = serviceName;
          WorkingDirectory = cfg.dataDir;
          ReadWritePaths = cfg.dataDir;
        };
      };

      systemd.tmpfiles.rules = [
        "d ${cfg.dataDir} 0755 ${serviceName} ${serviceName}"
      ];

      services.uptime-kuma = {
        enable = true;
        appriseSupport = false;
        package = pkgs.unstable.uptime-kuma;

        settings = {
          UPTIME_KUMA_DB_TYPE = "sqlite";
          UPTIME_KUMA_IN_CONTAINER = "false";
          UPTIME_KUMA_DISABLE_FRAME_SAMEORIGIN = "false";
          UPTIME_KUMA_ALLOW_ALL_CHROME_EXEC = "1";

          NODE_ENV = "production";

          HOST = "127.0.0.1";
          PORT = builtins.toString cfg.port;
          DATA_DIR = lib.mkForce cfg.dataDir;
        };
      };
    };
}
