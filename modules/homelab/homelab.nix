{ delib, ... }:
let
  inherit (delib)
    moduleOptions
    module
    strOption
    boolOption
    listOfOption
    str
    ;
in
module {
  name = "homelab";

  options = moduleOptions {
    enable = boolOption false;
    domain = strOption "local.zonni.pl";
    rootDomain = strOption "zonni.pl";
    users = {
      db = listOfOption str [ ];
      monitoring = listOfOption str [ ];
      auth = listOfOption str [ ];
    };
  };

  myconfig.ifEnabled.user.groups = [
    "db"
    "monitoring"
  ];

  nixos.ifEnabled =
    { cfg, ... }:
    {
      users.groups.db.gid = 3000;
      users.groups.monitoring.gid = 3001;
      users.groups.auth.gid = 3002;
      users.groups.db.members = cfg.users.db;
      users.groups.monitoring.members = cfg.users.monitoring;
      users.groups.monitoring.auth = cfg.users.authorization;
    };
}
