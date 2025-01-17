{
  inputs,
  lib,
  mylib,
  pkgs,
  ...
}:

with lib;
with mylib;
{
  mkHome =
    path:
    attrs@{
      system,
      stateVersion,
      ...
    }:
    let
      username = removeSuffix ".nix" (baseNameOf path);
      homeDirectory = "/home/${username}";

      osConfig = import ../hosts/corn/default.nix;

      defaults =
        {
          config,
          pkgs,
          lib,
          ...
        }:
        {
          systemd.user.startServices = "sd-switch";
          news.display = "silent";
          programs.home-manager.enable = true;
          xdg.enable = true;
          targets.genericLinux.enable = true;
          home.stateVersion = stateVersion;
          home.username = username;
          home.homeDirectory = homeDirectory;
        };
    in
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = (mapModulesRec' (toString ../modules/home) import) ++ [
        defaults
        (filterAttrs (
          n: v:
          !elem n [
            "system"
            "stateVersion"
          ]
        ) attrs)
        (import path)
      ];
      extraSpecialArgs = {
        inherit
          inputs
          system
          stateVersion
          mylib
          ;
      };
    };

  mapHomes = attrs: mapModules ../homes (homePath: mkHome homePath attrs);
}
