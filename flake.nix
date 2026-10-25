{
  description = "My Home NixOS configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
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

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-extra = {
      url = "git+ssh://gitea@git.tomato.local.zonni.pl/zonni/nixos-extra.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
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
    in
    {
      nixosConfigurations =
        (mkConfigurations "nixos" "zonni" ./hosts) // (mkConfigurations "nixos" "nixos" ./special/seed);
      homeConfigurations = mkConfigurations "home" "zonni" ./hosts;
    };
}
