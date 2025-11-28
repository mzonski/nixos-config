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

  nixos.ifEnabled = {
    users.groups.db.gid = 3000;
  };
}
