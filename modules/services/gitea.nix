{
  delib,
  inputs,
  config,
  lib,
  pkgs,
  host,
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
  serviceName = "gitea";
  mirrorName = "gitea-mirror";
in
module {
  name = "services.gitea";

  options = moduleOptions {
    enable = boolOption false;
    dbDir = strOption "/nas/database/${serviceName}";
    uiPort = intOption 8084;
    mirror = {
      enable = boolOption true;
      dataDir = strOption "/nas/database/${mirrorName}";
      port = intOption 8093;
    };
  };

  myconfig.ifEnabled =
    { cfg, ... }:
    {
      homelab.db.${serviceName} = {
        type = "postgres";
      };
      homelab.reverse-proxy.${serviceName} = {
        port = cfg.uiPort;
        subdomain = "git";
        requireAuth = false;
      };
      homelab.reverse-proxy.${mirrorName} = lib.mkIf cfg.mirror.enable {
        port = cfg.mirror.port;
        subdomain = "mirror-git";
        requireAuth = false;
      };
      user.groups = [ serviceName ] ++ lib.optional cfg.mirror.enable mirrorName;
      homelab.users.db = [ serviceName ];
    };

  nixos.always.imports = [ inputs.nixZpkgs.nixosModules.gitea-mirror ];

  nixos.ifEnabled =
    { myconfig, cfg, ... }:
    let
      gitDomain = "git.${host.name}.${myconfig.homelab.domain}";
      mirrorDomain = "https://mirror-git.${host.name}.${myconfig.homelab.domain}";
    in
    {
      users.users.${mirrorName} = lib.mkIf cfg.mirror.enable {
        uid = 980;
        group = mirrorName;
      };
      users.groups.${mirrorName} = lib.mkIf cfg.mirror.enable { gid = 980; };

      systemd.services.${mirrorName} = lib.mkIf cfg.mirror.enable {
        after = [ "zfs.target" ];
        requires = [ "zfs.target" ];
      };

      services.${mirrorName} = lib.mkIf cfg.mirror.enable {
        enable = true;
        dataDir = cfg.mirror.dataDir;
        user = mirrorName;
        group = mirrorName;
        host = "127.0.0.1";
        inherit (cfg.mirror) port;
        betterAuthUrl = mirrorDomain;
        betterAuthTrustedOrigins = mirrorDomain;
        mirrorIssueConcurrency = 1;
        mirrorPullRequestConcurrency = 1;
        environmentFile = config.sops.templates."${mirrorName}-env".path;
        openFirewall = false;
      };

      users.users.${serviceName}.uid = 990;
      users.groups.${serviceName}.gid = 985;

      sops =
        let
          sopsConfig = {
            sopsFile = host.secretsFile;
            owner = serviceName;
            group = serviceName;
          };
          mirrorSopsConfig = sopsConfig // {
            owner = mirrorName;
            group = mirrorName;
          };
        in
        {
          secrets.gitea_camo_hmac = sopsConfig;
          secrets.gitea_mirror_better_auth_secret = lib.mkIf cfg.mirror.enable mirrorSopsConfig;
          secrets.gitea_mirror_encryption_secret = lib.mkIf cfg.mirror.enable mirrorSopsConfig;
          templates."${mirrorName}-env" = lib.mkIf cfg.mirror.enable {
            inherit (mirrorSopsConfig) owner group;
            content = ''
              BETTER_AUTH_SECRET=${config.sops.placeholder.gitea_mirror_better_auth_secret}
              ENCRYPTION_SECRET=${config.sops.placeholder.gitea_mirror_encryption_secret}
            '';
          };
          # secrets.maxmind_license_key = sopsConfig;
          secrets.gitea_runner_token = {
            sopsFile = host.secretsFile;
          };
          secrets.ssh_private_gitea_ci = {
            owner = serviceName;
            group = serviceName;
          };
          templates."${serviceName}-runner-known-hosts".content = ''
            ${gitDomain},127.0.0.1 ${config.sops.placeholder."ssh_public_${host.name}"}
          '';
        };

      systemd.services.gitea = {
        after = [ "postgresql.service" ];
        requires = [ "postgresql.service" ];
      };

      nix.settings.allowed-users = [ "gitea-runner" ];

      systemd.services."gitea-runner-${serviceName}" = {
        serviceConfig.LoadCredential = [
          "ssh_key:${config.sops.secrets.ssh_private_gitea_ci.path}"
          "known_hosts:${config.sops.templates."${serviceName}-runner-known-hosts".path}"
        ];
        environment = {
          GIT_SSH_COMMAND = "${pkgs.openssh}/bin/ssh -i %d/ssh_key -o IdentitiesOnly=yes -o GlobalKnownHostsFile=%d/known_hosts";
          GIT_CONFIG_SYSTEM = pkgs.writeText "gitea-runner-gitconfig" ''
            [user]
              name = ci
              email = ci@zonni.pl
            [url "gitea@127.0.0.1:"]
              insteadOf = http://127.0.0.1:${toString cfg.uiPort}/
          '';
        };
      };

      services.gitea-actions-runner.instances.${serviceName} = {
        enable = true;
        name = "${host.name}-runner";
        url = "http://127.0.0.1:${toString cfg.uiPort}";
        tokenFile = config.sops.secrets.gitea_runner_token.path;
        labels = [ "native:host" ];
        hostPackages = with pkgs; [
          bash
          coreutils
          curl
          gawk
          git
          gnused
          nodejs
          openssh
          wget
          nix
        ];
        settings = {
          log.level = "info";
          runner = {
            capacity = 2;
            timeout = "3h";
            shutdown_timeout = "5s";
            insecure = false;
            fetch_timeout = "5s";
            fetch_interval = "2s";
          };
          cache = {
            enabled = true;
          };
        };
      };

      services.gitea = {
        enable = true;
        stateDir = cfg.dbDir;
        user = serviceName;
        group = serviceName;
        database = {
          createDatabase = false;
          type = "postgres";
          socket = "/run/postgresql";
          host = "127.0.0.1";
          port = myconfig.services.postgres.port;
          name = serviceName;
          user = serviceName;
        };
        captcha.enable = false;
        dump.enable = false;
        lfs.enable = true;

        appName = "Homelab Git";
        camoHmacKeyFile = config.sops.secrets.gitea_camo_hmac.path;
        settings =
          let
            domain = "https://${gitDomain}/";
          in
          {
            repository = {
              DISABLE_HTTP_GIT = true;
              ACCESS_CONTROL_ALLOW_ORIGIN = domain;
              DEFAULT_REPO_UNITS = "repo.code,repo.actions";
            };
            "repository.pull-request" = {
              DEFAULT_MERGE_STYLE = "squash";
            };
            "repository.upload" = {
              ALLOWED_TYPES = "*/*";
            };
            "repository.release" = {
              ALLOWED_TYPES = "*/*";
            };
            cors = {
              ALLOW_DOMAIN = domain;
            };
            ui = {
              SHOW_USER_EMAIL = false;
            };
            "ui.meta" = {
              AUTHOR = "Homelab";
              DESCRIPTION = "Homelab Git";
            };
            server = {
              HTTP_PORT = cfg.uiPort;
              DOMAIN = gitDomain;
              ROOT_URL = domain;
              SSH_PORT = 22;
              LANDING_PAGE = "login";
            };
            security = {
              INSTALL_LOCK = true;
            };

            service = {
              DISABLE_REGISTRATION = true;
              ENABLE_BASIC_AUTHENTICATION = false;
              ENABLE_PASSWORD_SIGNIN_FORM = false;
              ENABLE_NOTIFY_MAIL = true;
            };
            mailer = {
              ENABLED = true;
              PROTOCOL = "smtp";
              SMTP_ADDR = "127.0.0.1";
              SMTP_PORT = 25;
              FROM = "gitea@${gitDomain}";
            };
            "service.explore" = {
              REQUIRE_SIGNIN_VIEW = true;
            };
            cron = {
              ENABLED = true;
            };
            i18n = {
              LANGS = "en-US,pl-PL";
              NAMES = "English,Polski";
            };
            other = {
              SHOW_FOOTER_VERSION = false;
              SHOW_FOOTER_TEMPLATE_LOAD_TIME = false;
              SHOW_FOOTER_POWERED_BY = false;
              ENABLE_SITEMAP = false;
              ENABLE_FEED = false;
            };
            api = {
              ENABLE_SWAGGER = false;
            };
          };
      };
    };
}
