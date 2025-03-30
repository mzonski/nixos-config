{ delib, ... }:
delib.module {
  name = "hosts";

  options =
    with delib;
    let
      host =
        { config, ... }:
        {
          options = hostSubmoduleOptions // {
            type = noDefault (enumOption [ "desktop" "server" "minimal" ] null);

            isDesktop = boolOption (config.type == "desktop");
            isServer = boolOption (config.type == "server");
            isMinimal = boolOption (config.type == "minimal");
            not = {
              isDesktop = boolOption (config.type != "desktop");
              isServer = boolOption (config.type != "server");
              isMinimal = boolOption (config.type != "minimal");
            };
          };
        };
    in
    {
      host = hostOption host;
      hosts = hostsOption host;
    };

  myconfig.always =
    { myconfig, ... }:
    {
      args.shared = {
        inherit (myconfig) host hosts;
      };
    };

  home.always =
    { myconfig, ... }:
    {
      assertions = delib.hostNamesAssertions myconfig.hosts;
    };
}
