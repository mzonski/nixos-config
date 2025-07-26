# https://github.com/yunfachi/denix/blob/cbd8b8e09b64cedad7380a34abe8a3a4e332a561/lib/extensions/base/rices.nix
{ delib, lib, ... }:
delib.extension {
  name = "mybase";

  config = final: prev: {
    rices = {
      enable = final.enableAll;
      inherit (final) args assertions;
    };
  };

  modules =
    config:
    lib.optionals config.rices.enable [
      (
        { delib, ... }:
        let
          assertionsConfig =
            { myconfig, ... }:
            {
              assertions = delib.riceNamesAssertions myconfig.rices;
            };
          assertionsModuleSystem =
            {
              nixos = "nixos";
              home-manager = "home";
              nix-darwin = "darwin";
            }
            .${config.rices.assertions.moduleSystem} or config.rices.assertions.moduleSystem;
        in
        delib.module (
          {
            name = "rices";

            options =
              with delib;
              let
                themeOption = {
                  name = noDefault (strOption null);
                  package = noDefault (packageOption null);
                };

                themeSizeOption = {
                  inherit (themeOption) name package;
                  size = noDefault (intOption null);
                };

                rice = {
                  # TODO: Move to a separate myconfig module
                  options = riceSubmoduleOptions // {
                    packages = listOfOption package [ ];
                    fonts = {
                      monospace = themeSizeOption;
                      sans = themeSizeOption;
                      emoji = themeSizeOption;
                    };
                    cursor = themeSizeOption;
                    icons = themeOption;
                    gtkThemeName = noDefault (strOption null);
                    wallpaper = noDefault (pathOption null);
                  };
                };
              in
              {
                rice = riceOption rice;
                rices = ricesOption rice;
              };

            myconfig.always =
              { myconfig, ... }:
              lib.optionalAttrs config.rices.args.enable (
                delib.setAttrByStrPath config.rices.args.path {
                  shared = { inherit (myconfig) rice rices; };
                }
              )
              // lib.optionalAttrs (assertionsModuleSystem == "myconfig") (
                lib.optionalAttrs config.rices.assertions.enable assertionsConfig
              );
          }
          // (lib.optionalAttrs (assertionsModuleSystem != "myconfig") {
            ${assertionsModuleSystem}.always =
              lib.optionalAttrs config.rices.assertions.enable assertionsConfig;
          })
        )
      )
    ];
}
