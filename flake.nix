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
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      inherit (lib')
        mapModules
        mapModulesRec
        mapHosts
        mapHomes
        ;

      system = "x86_64-linux";
      stateVersion = "24.11";

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

      lib = nixpkgs.lib;
      lib' = import ./lib { inherit pkgs inputs lib; };

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
    in
    {
      overlays.default = overlay;

      packages."${system}" = mapModules ./packages (p: pkgs.callPackage p { inherit inputs; });

      nixosModules = mapModulesRec ./modules/system import;

      nixosConfigurations = mapHosts { inherit system stateVersion; };

      homeConfigurations = mapHomes { inherit system stateVersion; };
    };
}
