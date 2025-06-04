{
  delib,
  lib,
  inputs,
  ...
}:
let
  shared.nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "archiver-3.5.1"
    ];
  };

  shared.nixpkgs.overlays = [
    (
      final: prev:
      let
        inherit (final.stdenv.hostPlatform) system;
        inherit (final) config;

        unstable = import inputs.nixpkgs-unstable {
          inherit system config;
        };
      in
      {
        inherit unstable;
        hyprFlake = inputs.hyprland.packages.${system};
        hyprPluginsFlake = inputs.hyprland-plugins.packages.${system};
        firefoxAddons = inputs.firefox-addons.packages.${system};
        local = builtins.listToAttrs (
          map (path: {
            name = baseNameOf (dirOf path);
            value = unstable.callPackage path { inherit inputs; };
          }) (inputs.denix.lib.umport { path = ../../packages; })
        );
      }
      // (import ../../overlays) final prev
    )
  ];

  # TODO: /root/.config/nixpkgs/config.nix
  files."nixpkgs/config.nix".text = ''
    {
      allowUnfree = true;
    }
  '';
  variables."NIXPKGS_ALLOW_UNFREE" = 1;

  mkConfig = extras: lib.recursiveUpdate shared extras;

in
delib.module {
  name = "nixpkgs";

  nixos.always = mkConfig {
    environment.variables = variables;
  };
  home.always = mkConfig {
    xdg.configFile = files;
    home.sessionVariables = variables;
  };
}
