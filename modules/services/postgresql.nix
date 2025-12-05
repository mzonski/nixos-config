{
  delib,
  homeManagerUser,
  pkgs,
  host,
  config,
  ...
}:

let
  inherit (delib)
    module
    boolOption
    strOption
    intOption
    moduleOptions
    ;
  serviceName = "postgres";
in
module {
  name = "services.postgres";

  options = moduleOptions {
    enable = boolOption false;
    port = intOption 5432;
    filesDir = strOption "/nas/database/${serviceName}";
  };

  myconfig.ifEnabled = {
    user.groups = [ serviceName ];
    homelab.users.db = [ serviceName ];
  };

  nixos.ifEnabled =
    { myconfig, cfg, ... }:
    let
      dataDir = "${cfg.filesDir}/data";
      logDir = "${cfg.filesDir}/logs";
    in
    {
      networking.firewall.allowedTCPPorts = [ cfg.port ];

      sops =
        let
          sopsConfig = {
            sopsFile = host.secretsFile;
            owner = serviceName;
            group = serviceName;
          };
        in
        {
          secrets.postgres_password = sopsConfig;
          secrets.postgres_key = sopsConfig;
          secrets.postgres_crt = sopsConfig;
        };

      systemd.tmpfiles.rules = [
        "d ${cfg.filesDir} 0700 ${serviceName} ${serviceName} - -"
        "d ${dataDir} 0700 ${serviceName} ${serviceName} - -"
        "d ${logDir} 0700 ${serviceName} ${serviceName} - -"
      ];

      systemd.services.postgresql = {
        after = [ "zfs.target" ];
        requires = [ "zfs.target" ];
      };

      services.postgresql = {
        enable = true;
        enableJIT = false;
        enableTCPIP = true;
        package = pkgs.postgresql;
        inherit dataDir;

        checkConfig = true;

        initdbArgs = [
          "--encoding=UTF8"
          "--locale=C"
          "--data-checksums"
          "--allow-group-access"
        ];

        ensureDatabases = [ homeManagerUser ];
        ensureUsers = [
          {
            name = homeManagerUser;
            ensureDBOwnership = false;
            ensureClauses = {
              login = true;
              superuser = true;
            };
          }
        ];

        authentication = ''
          # TYPE  DATABASE    USER                ADDRESS                 METHOD

          # Local connections
          local   all         postgres                                    peer
          local   all         ${homeManagerUser}                          peer

          # TCP/IP connections
          host    all         all                 127.0.0.1/32            scram-sha-256
          host    all         all                 10.0.1.0/24             scram-sha-256
          host    all         all                 0.0.0.0/0               reject
        '';

        identMap = ''
          # MAPNAME       SYSTEM-USERNAME         PG-USERNAME
          postgres        root                    postgres
        '';

        settings = {
          port = cfg.port;

          shared_buffers = "128MB";
          effective_cache_size = "256MB";
          maintenance_work_mem = "32MB";
          work_mem = "4MB";

          log_directory = logDir;
          log_filename = "postgresql-%Y-%m-%d_%H%M%S.log";
          log_rotation_age = "1d";
          log_rotation_size = "100MB";
          log_min_duration_statement = 1000;
          log_lock_waits = true;
          log_statement = "ddl";
          log_temp_files = 0;

          autovacuum_naptime = "30min";

          ssl = true;
          ssl_cert_file = config.sops.secrets.postgres_crt.path;
          ssl_key_file = config.sops.secrets.postgres_key.path;

          checkpoint_completion_target = 0.9;
        };

        systemCallFilter = {
          "@system-service" = true;
          "~@privileged" = true;
          "~@resources" = false;

          "~@mount" = true;
          "~@swap" = true;
          "~@reboot" = true;
          "~@module" = true;
          "~@raw-io" = true;
          "~@debug" = true;
        };
      };

      systemd.services.postgresql-log-cleanup = {
        script = ''
          find ${logDir} -name "postgresql-*.log" -mtime +30 -delete
        '';
      };

      systemd.timers.postgresql-log-cleanup = {
        wantedBy = [ "timers.target" ];
        partOf = [ "postgresql-log-cleanup.service" ];
        timerConfig.OnCalendar = "daily";
      };

      systemd.services.postgresql-password-setup = {
        description = "Set PostgreSQL user passwords";
        after = [ "postgresql.service" ];
        requires = [ "postgresql.service" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "oneshot";
          User = serviceName;
          RemainAfterExit = true;
        };

        script = ''
          ${config.services.postgresql.package}/bin/psql -c "ALTER USER ${homeManagerUser} WITH PASSWORD '$(cat ${config.sops.secrets.postgres_password.path})';"
        '';
      };
    };
}
