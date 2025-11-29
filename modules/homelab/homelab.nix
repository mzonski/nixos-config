{ delib, ... }:
let
  inherit (delib)
    module
    strOption
    boolOption
    ;
in
module {
  name = "homelab";

  options.homelab = {
    enable = boolOption false;
    domain = strOption "local.zonni.pl";
    rootDomain = strOption "zonni.pl";
  };

  myconfig.ifEnabled.user.groups = [
    "db"
    "monitoring"
  ];

  nixos.ifEnabled = {
    users.groups.db.gid = 3000;
    users.groups.monitoring.gid = 3001;
  };
}
