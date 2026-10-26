{
  delib,
  config,
  pkgs,
  host,
  ...
}:
let
  inherit (delib)
    module
    boolOption
    intOption
    moduleOptions
    strOption
    ;
  serviceName = "hydra";
in
module {
  name = "services.hydra";

  options = moduleOptions {
    enable = boolOption false;
    port = intOption 8090;
    domainUrl = strOption "";
  };

  myconfig.ifEnabled =
    { myconfig, cfg, ... }:
    {
      services.${serviceName}.domainUrl = "https://${serviceName}.${myconfig.homelab.rootDomain}";

      homelab.reverse-proxy.${serviceName} = {
        port = cfg.port;
        root = true;
        requireAuth = false;
      };
    };

  nixos.ifEnabled =
    { myconfig, cfg, ... }:
    {
      sops =
        let
          sopsConfig = {
            sopsFile = host.secretsFile;
            owner = serviceName;
            group = serviceName;
          };
        in
        {
          secrets.hydra_binary_cache_secret_private = sopsConfig // {
            mode = "0440";
          };
          secrets.hydra_binary_cache_secret_public = sopsConfig // {
            mode = "0444";
          };
        };

      services.hydra = {
        inherit (cfg) port;
        enable = true;
        hydraURL = cfg.domainUrl;
        notificationSender = "hydra@homelab";
        buildMachinesFiles = [ ];
        useSubstitutes = true;
        listenHost = "127.0.0.1";
        smtpHost = "127.0.0.1";

        extraConfig = ''
          email_notification = 1
          binary_cache_secret_key_file = ${config.sops.secrets.hydra_binary_cache_secret_private.path}
        '';
      };

      systemd.services.hydra-init = {
        after = [ "postgresql.service" ];
        requires = [ "postgresql.service" ];
      };

      systemd.services.hydra-evaluator = {
        serviceConfig.LoadCredential = [
          "ssh_key:${config.sops.secrets.ssh_private_gitea_ci.path}"
          "known_hosts:${config.sops.templates."gitea-runner-known-hosts".path}"
        ];
        environment.GIT_SSH_COMMAND = "${pkgs.openssh}/bin/ssh -i %d/ssh_key -o IdentitiesOnly=yes -o GlobalKnownHostsFile=%d/known_hosts";
      };

      nix.settings.allowed-users = [
        "hydra"
        "hydra-www"
      ];

      nix.settings.allowed-uris = [
        "github:"
        "git+https://github.com/"
        "git+ssh://github.com/"
        "git+ssh://tomato/"
        "git+ssh://gitea@git.${host.name}.${myconfig.homelab.domain}/"
      ];
    };
}
