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

    hyprland.url = "github:hyprwm/Hyprland/v0.46.2";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins/b8293c3608f5fcdc342eb0cfef663a13097c3929";
      inputs.hyprland.follows = "hyprland";
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
      lib = nixpkgs.lib;
      system = "x86_64-linux";

      pkgs = mkPkgs nixpkgs ((lib.attrValues self.overlays));
      unstable = mkPkgs inputs.nixpkgs-unstable [ ];

      overlay =
        final: prev:
        {
          inherit unstable;
          hyprFlake = inputs.hyprland.packages.${system};
          hyprPluginsFlake = inputs.hyprland-plugins.packages.${system};
          firefoxAddons = inputs.firefox-addons.packages.${system};
          local = self.packages."${system}";
        }
        // (import ./overlays) final prev;

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
