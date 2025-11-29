{
  delib,
  lib,
  host,
  ...
}:
let
  inherit (delib)
    moduleOptions
    module
    boolOption
    ;

  defaultSopsConfig = {
    sopsFile = host.secretsFile;
    mode = "0440";
  };

  mkSecrets =
    group: secretNames: lib.genAttrs secretNames (_: defaultSopsConfig // { inherit group; });
in
module {
  name = "homelab.secrets";

  options = moduleOptions (
    { parent, ... }:
    {
      enable = boolOption parent.enable;
      haveAnyAuthUser = boolOption (parent.users.auth != [ ]);
      haveAnyMonitoringUser = boolOption (parent.users.monitoring != [ ]);
    }
  );

  nixos.ifEnabled =
    { cfg, ... }:
    {
      sops.secrets =
        (lib.optionalAttrs cfg.haveAnyMonitoringUser (
          mkSecrets "monitoring" [
            "influxdb_grafana_read_token"
          ]
        ))
        // (lib.optionalAttrs cfg.haveAnyAuthUser (
          mkSecrets "auth" [
            "oidc_google_client_id"
            "oidc_google_secret"
          ]
        ));
    };
}
