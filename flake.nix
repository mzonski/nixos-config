{
  description = "My Home NixOS configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
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
      url = "github:mzonski/denix/84b6310afdccbe8de6db03df77e248d958d4a54b";
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
      lib = nixpkgs.lib;
      system = "x86_64-linux";

      mylib = import ./lib { inherit lib; };
      pkgs = mkPkgs nixpkgs ((lib.attrValues self.overlays));

      mkPkgs =
        pkgs: overlays:
        import pkgs {
          inherit system;
          config.allowUnfree = true;
          config.permittedInsecurePackages = [
            "archiver-3.5.1"
          ];
          overlays = overlays;
        };

      overlay =
        final: prev:
        {
          unstable = mkPkgs inputs.nixpkgs-unstable [ ];
          hyprland = inputs.hyprland.packages.${system};
          hyprplugins = inputs.hyprland-plugins.packages.${system};
          firefoxAddons = inputs.firefox-addons.packages.${system};
          local = self.packages."${system}";
        }
        // (import ./overlays) final prev;

      mkConfigurations =
        isHomeManager:
        denix.lib.configurations rec {
          homeManagerNixpkgs = nixpkgs;
          homeManagerUser = "zonni";
          inherit isHomeManager;

          paths = [
            ./hosts
            ./rices
            ./modules
          ];

          specialArgs = {
            inherit
              inputs
              isHomeManager
              homeManagerUser
              pkgs
              system
              mylib
              ;
          };
        };
    in
    {
      overlays.default = overlay;

      packages."${system}" = builtins.listToAttrs (
        map (path: {
          name = baseNameOf (dirOf path);
          value = pkgs.callPackage path { inherit inputs; };
        }) (denix.lib.umport { path = ./packages; })
      );

      nixosConfigurations = mkConfigurations false;
      homeConfigurations = mkConfigurations true;
    };
}
