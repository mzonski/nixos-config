{
  delib,
  config,
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

  nixos.always = { myconfig, cfg, ... }: {
    nix.settings = {
      substituters = [
        myconfig.services.${serviceName}.domainUrl
      ];
      trusted-substituters = [
        myconfig.services.${serviceName}.domainUrl
      ];

      trusted-public-keys = [
        "hydra.zonni.pl:icN1z9gO7ekAyzVJ2vHQSqYgNrg+m4pbj/8h/SXwY5s="
      ];
    };
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
          secrets.hydra_binary_cache_secret_private = sopsConfig;
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

        extraConfig = ''
          binary_cache_secret_key_file = ${config.sops.secrets.hydra_binary_cache_secret_private.path}
        '';
      };

      systemd.services.hydra-init = {
        after = [ "postgresql.service" ];
        requires = [ "postgresql.service" ];
      };

      nix.settings.allowed-uris = [
        "github:"
        "git+https://github.com/"
        "git+ssh://github.com/"
        "git+ssh://tomato/"
      ];
    };
}
