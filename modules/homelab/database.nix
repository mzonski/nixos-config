{
  delib,
  lib,
  ...
}:
let
  inherit (delib)
    module
    attrsOfOption
    submodule
    enumOption
    strOption
    assertEnabled
    allowNull
    boolOption
    ;
  inherit (lib) mkIf;
  inherit (lib.attrsets) filterAttrs mapAttrsToList;
in
module {
  name = "homelab.db";

  options.homelab.db = attrsOfOption (submodule {
    options = {
      onlyLocal = boolOption true;
      passwordPath = allowNull (strOption null);
      type = allowNull (enumOption [ "postgres" ] null);
    };
  }) { };

  nixos.always =
    { myconfig, cfg, ... }:
    let
      filterByDbType = type: filterAttrs (name: dbCfg: dbCfg.type == type) cfg;
    in
    mkIf (cfg != { }) {
      assertions = [
        (assertEnabled myconfig "services.postgres.enable")
      ];

      systemd.services.postgresql.after = mkIf myconfig.features.zfs.enable [ "nfs-mountd.service" ];

      services.postgresql =
        let
          postgresDatabases = filterByDbType "postgres";
        in
        {
          ensureDatabases = mapAttrsToList (name: dbCfg: name) postgresDatabases;
          ensureUsers = mapAttrsToList (name: dbCfg: {
            name = name;
            ensureDBOwnership = true;
            ensureClauses = {
              login = true;
            };
          }) postgresDatabases;

          authentication = lib.mkBefore (
            lib.concatStrings (
              mapAttrsToList (name: dbCfg: ''
                local ${name} ${name} ${if dbCfg.onlyLocal then "peer" else "scram-sha-256"}
                host ${name} ${name} ${if dbCfg.onlyLocal then "127.0.0.1/32" else "10.0.1.0/32"} ${
                  if dbCfg.onlyLocal then "trust" else "scram-sha-256"
                }
              '') postgresDatabases
            )
          );
        };
    };
}
