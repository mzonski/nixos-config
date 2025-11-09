{ delib, ... }:
let
  inherit (delib)
    noDefault
    pathOption
    ;
in
delib.extension {
  name = "extend-host-options";
  description = "Extends Denix host options";

  libExtension = _: _: prev: {
    hostSubmoduleOptions = prev.hostSubmoduleOptions // {
      secretsFile = noDefault (pathOption null);
    };
  };
}
