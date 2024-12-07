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
    catppuccin.url = "github:catppuccin/nix";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      ...
    }:
    let
      inherit (mylib)
        mapModules
        mapModulesRec
        mapHosts
        mapHomes
        ;

      system = "x86_64-linux";
      stateVersion = "24.11";

      mkPkgs =
        pkgs: overlays:
        import pkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = overlays;
        };
      pkgs = mkPkgs nixpkgs (lib.attrValues self.overlays);
      pkgs' = mkPkgs nixpkgs-unstable [ ];

      lib = nixpkgs.lib;
      mylib = import ./lib { inherit pkgs inputs lib; };

      overlay =
        final: prev:
        {
          unstable = pkgs';
          my = self.packages."${system}";
        }
        // (import ./overlays { inherit inputs; }) final prev;
    in
    {
      overlays.default = overlay;

      packages."${system}" = mapModules ./packages (p: pkgs.callPackage p { inherit inputs; });

      nixosModules = mapModulesRec ./modules import;

      nixosConfigurations = mapHosts ./hosts { inherit system stateVersion; };

      homeConfigurations = mapHomes ./homes { inherit system stateVersion; };
    };
}
