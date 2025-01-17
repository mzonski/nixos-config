{
  description = "My Home NixOS configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/efd9668e9b64c716a793cac7785e369766b4d7c0";

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
      nixpkgs-master,
      hyprland-contrib,
      hyprland,
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
      #
      pkgs = mkPkgs nixpkgs ((lib.attrValues self.overlays));
      pkgs' = mkPkgs nixpkgs-unstable [ ];
      masterPkgs = mkPkgs inputs.nixpkgs-master [ ];

      lib = nixpkgs.lib;
      mylib = import ./lib { inherit pkgs inputs lib; };

      overlay =
        final: prev:
        {
          unstable = pkgs';
          master = masterPkgs;
          my = self.packages."${system}";
        }
        // (import ./overlays) final prev;
    in
    {
      overlays.default = overlay;

      packages."${system}" = mapModules ./packages (p: pkgs.callPackage p { inherit inputs; });

      nixosModules = mapModulesRec ./modules import;

      nixosConfigurations = mapHosts { inherit system stateVersion; };

      homeConfigurations = mapHomes { inherit system stateVersion; };
    };
}
