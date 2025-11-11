{
  delib,
  host,
  ...
}:
delib.module {
  name = "networking";

  options.networking = with delib; {
    hosts = attrsOfOption (listOf str) { };
  };

  nixos.always =
    { cfg, ... }:
    {
      networking = {
        hostName = host.name;

        firewall.enable = true;
      };
    };
}
