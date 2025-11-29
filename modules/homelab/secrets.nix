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
in
module {
  name = "homelab.secrets";

  options = moduleOptions (
    { parent, ... }:
    {
      haveAnyAuthUser = boolOption (parent.users.auth != [ ]);
      haveAnyMonitoringUser = boolOption (parent.users.monitoring != [ ]);
    }
  );

  nixos.ifEnabled =
    { cfg, ... }:
    let
      defaultSopsConfig = {
        sopsFile = host.secretsFile;
        mode = "0440";
      };

      mkSecrets =
        group: secretNames: lib.genAttrs secretNames (_: defaultSopsConfig // { inherit group; });
    in
    {
      sops.secrets =
        (lib.optionalAttrs cfg.haveAnyMonitoringUser (
          mkSecrets "monitoring" [
            "influxdb_grafana_read_token"
            "influxdb_grafana_password"
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
