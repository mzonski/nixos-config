{
  inputs,
  lib,
  lib',
  pkgs,
  ...
}:
let
  inherit (lib') mapModulesRec' mapModules mkHome;
  inherit (lib) removeSuffix;
in
{
  mkHome =
    path:
    _@{
      system,
      stateVersion,
      ...
    }:
    let
      username = removeSuffix ".nix" (baseNameOf path);
      homeDirectory = "/home/${username}";

      defaults = {
        systemd.user.startServices = "sd-switch";
        news.display = "silent";
        programs.home-manager.enable = true;
        xdg.enable = true;
        targets.genericLinux.enable = true;
        home.stateVersion = stateVersion;
        home.username = username;
        home.homeDirectory = homeDirectory;
        nix.gc = {
          automatic = true;
          persistent = true;
          frequency = "weekly";
          options = "--delete-old";
        };
      };
    in
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = (mapModulesRec' (toString ../modules/home) import) ++ [
        defaults
        (import path)
      ];
      extraSpecialArgs = {
        inherit
          inputs
          system
          stateVersion
          lib'
          ;
      };
    };

  mapHomes = attrs: mapModules ../homes (homePath: mkHome homePath attrs);
}
