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
  inherit (inputs.home-manager.lib) homeManagerConfiguration;
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
    homeManagerConfiguration {
      inherit pkgs;
      modules = (mapModulesRec' (toString ../modules/home) import) ++ [
        defaults
        (import path)
        inputs.sops-nix.homeManagerModules.sops
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
