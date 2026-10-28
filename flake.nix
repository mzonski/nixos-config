{
  description = "My Home NixOS configuration flake";

  inputs = {
    nixZpkgs = {
      url = "git+ssh://gitea@git.tomato.local.zonni.pl/ZONIA/nixZpkgs.git";
    };

    nixpkgs.follows = "nixZpkgs/nixpkgs";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    denix = {
      url = "github:yunfachi/denix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    inputs@{
      self,
      denix,
      nixpkgs,
      ...
    }:
    let
      system = "x86_64-linux";

      mkConfigurations =
        moduleSystem: homeManagerUser: path:
        denix.lib.configurations rec {
          homeManagerNixpkgs = nixpkgs;
          inherit homeManagerUser moduleSystem;

          paths = [
            path
            ./rices
            ./modules
            ./overlays
          ];

          extensions = import ./extensions { delib = denix.lib; };

          specialArgs = {
            inherit
              inputs
              moduleSystem
              homeManagerUser
              system
              ;
          };
        };

      denixHosts = mkConfigurations "nixos" "zonni" ./hosts;

      mkGraft =
        name:
        denixHosts.${name}.extendModules { modules = denix.lib.umport { paths = [ ./special/graft ]; }; };
    in
    {
      nixosConfigurations =
        denixHosts // (mkConfigurations "nixos" "nixos" ./special/seed) // { graft-corn = mkGraft "corn"; };
      homeConfigurations = mkConfigurations "home" "zonni" ./hosts;
    };
}
