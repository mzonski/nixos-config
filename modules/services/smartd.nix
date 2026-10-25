{ delib, ... }:
let
  inherit (delib)
    module
    boolOption
    listOfOption
    str
    moduleOptions
    ;
in
module {
  name = "services.smartd";

  options = moduleOptions {
    enable = boolOption false;
    devices = listOfOption str [ ];
  };

  nixos.ifEnabled =
    { cfg, ... }:
    {
      services.smartd = {
        enable = true;
        autodetect = false;

        notifications.mail = {
          enable = true;
          recipient = "me@zonni.pl";
        };

        # Long test runs on the first Monday of the month, at 06:00
        # Short test runs every Monday except the first, at 08:00
        defaults.monitored = "-a -o on -s (L/../0[1-7]/1/06|S/../(0[89]|[12][0-9]|3[01])/1/08)";
        devices = map (device: { inherit device; }) cfg.devices;
      };
    };
}
