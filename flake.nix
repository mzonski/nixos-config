{
  description = "My Home NixOS configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    systems.url = "github:nix-systems/default-linux";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    nixgl.url = "github:guibou/nixGL";

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nil-ls.url = "github:oxalica/nil";

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    denix = {
      url = "github:yunfachi/denix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    flake-programs-sqlite = {
      url = "github:wamserma/flake-programs-sqlite";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko.url = "github:nix-community/disko";
    musnix.url = "github:musnix/musnix";
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

          extensions = (with denix.lib.extensions; [ args ]) ++ ([
            (
              (denix.lib.mergeExtensions "denix_extensions" [
                (denix.lib.callExtension ./extensions/base/default.nix)
                (denix.lib.callExtension ./extensions/base/hosts.nix)
                (denix.lib.callExtension ./extensions/base/rices.nix)
                (denix.lib.callExtension ./extensions/overlay-module.nix)
              ]).withConfig
              {
                args.enable = true;

                defaultOverlayTargets = [
                  "nixos"
                  "home"
                ];

                hosts.type.types = [
                  "desktop"
                  "server"
                  "minimal"
                ];
              }
            )
          ]);

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
