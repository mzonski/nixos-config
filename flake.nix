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

    disko.url = "github:nix-community/disko";

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    my-pc-rgb.url = "github:mzonski/my-pc-rgb/dev";

    asus-numberpad-driver = {
      url = "github:asus-linux-drivers/asus-numberpad-driver";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-programs-sqlite = {
      url = "github:wamserma/flake-programs-sqlite";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    speedtest-exporter.url = "git+ssh://gitea@tomato/zonni/speedtest-exporter.git";
    usb-sniffer.url = "git+ssh://gitea@tomato/zonni/usb-sniffer.git";
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
