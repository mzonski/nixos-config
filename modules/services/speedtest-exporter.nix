{ delib, inputs, ... }:
let
  inherit (delib)
    module
    boolOption
    intOption
    moduleOptions
    ;
  serviceName = "speedtest-exporter";
in
module {
  name = "services.${serviceName}";

  options = moduleOptions {
    enable = boolOption false;
    port = intOption 9798;
  };

  nixos.always = {
    imports = [ inputs.speedtest-exporter.nixosModules.default ];
  };

  nixos.ifEnabled =
    { myconfig, cfg, ... }:
    {
      services.speedtest-exporter = {
        inherit (cfg) port;
        enable = true;
        cacheDuration = 5 * 60;
        openFirewall = true;
      };
    };
}
