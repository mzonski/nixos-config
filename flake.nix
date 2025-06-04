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

      mkSpecialArgs =
        { moduleSystem, homeManagerUser }:
        {
          inherit
            inputs
            moduleSystem
            homeManagerUser
            system
            ;
        };

      mkConfigurations =
        moduleSystem:
        denix.lib.configurations rec {
          homeManagerNixpkgs = nixpkgs;
          homeManagerUser = "zonni";
          inherit moduleSystem;

          paths = [
            ./hosts
            ./rices
            ./modules
          ];

          specialArgs = mkSpecialArgs { inherit moduleSystem homeManagerUser; };
        };

      initConfiguration = denix.lib.configurations rec {
        homeManagerNixpkgs = nixpkgs;
        homeManagerUser = "nixos";
        moduleSystem = "nixos";

        paths = [
          ./special/initIso
          ./rices
          ./modules
        ];

        specialArgs = mkSpecialArgs { inherit moduleSystem homeManagerUser; };
      };
    in
    {
      nixosConfigurations = mkConfigurations "nixos" // initConfiguration;
      homeConfigurations = mkConfigurations "home";
    };
}
