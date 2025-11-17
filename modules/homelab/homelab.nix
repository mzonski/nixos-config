{ delib, ... }:
let
  inherit (delib)
    module
    strOption
    ;
in
module {
  name = "homelab";

  options.homelab = {
    domain = strOption "local.zonni.pl";
  };

  nixos.always = {
    users.groups.db.gid = 3000;
  };
}
