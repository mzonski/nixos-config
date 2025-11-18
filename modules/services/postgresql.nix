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
in
module {
  name = "services.postgres";

  options = moduleOptions {
    enable = boolOption false;
    port = intOption 5432;
    filesDir = strOption "/nas/database/postgres";
  };

  myconfig.ifEnabled.user.groups = [
    "postgres"
    "db"
  ];

  nixos.ifEnabled =
    { myconfig, cfg, ... }:
    let
      dataDir = "${cfg.filesDir}/data";
      logDir = "${cfg.filesDir}/logs";
    in
    {
      networking.firewall.allowedTCPPorts = [ cfg.port ];
      users.users.postgres.extraGroups = [ "db" ];

      sops =
        let
          sopsConfig = {
            sopsFile = host.secretsFile;
            owner = "postgres";
            group = "postgres";
          };
        in
        {
          secrets.postgres_password = sopsConfig;
          secrets.postgres_key = sopsConfig;
          secrets.postgres_crt = sopsConfig;
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
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "oneshot";
          User = "postgres";
          RemainAfterExit = true;
        };

        script = ''
          ${config.services.postgresql.package}/bin/psql -c "ALTER USER ${homeManagerUser} WITH PASSWORD '$(cat ${config.sops.secrets.postgres_password.path})';"
        '';
      };
    };
}
