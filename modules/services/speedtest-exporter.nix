{ delib, inputs, ... }:
let
  inherit (delib)
    module
    boolOption
    moduleOptions
    ;
  serviceName = "speedtest-exporter";
in
module {
  name = "services.${serviceName}";

  options = moduleOptions {
    enable = boolOption false;
  };

  nixos.always = {
    imports = [ inputs.speedtest-exporter.nixosModules.default ];
  };

  nixos.ifEnabled =
    { myconfig, cfg, ... }:
    {
      services.speedtest-exporter = {
        enable = true;
        port = 9798;
        cacheDuration = 5 * 60;
        openFirewall = true;
      };
    };
}
