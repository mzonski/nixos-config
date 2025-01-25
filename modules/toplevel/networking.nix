{
  delib,
  host,
  ...
}:
delib.module {
  name = "networking";

  options.networking = with delib; {
    nameservers = listOfOption str [
      "10.0.5.10"
      "1.1.1.1"
    ];
    hosts = attrsOfOption (listOf str) { };
  };

  nixos.always =
    { cfg, ... }:
    {
      networking = {
        hostName = host.name;

        firewall.enable = false;
        networkmanager.enable = false;
        useDHCP = true;

        inherit (cfg) nameservers;
      };
    };
}
