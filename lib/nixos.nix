{
  inputs,
  lib,
  lib',
  pkgs,
  ...
}:

with lib;
with lib';
{
  mkHost =
    path:
    attrs@{
      system,
      stateVersion,
      ...
    }:
    let
      defaults = {
        imports = [
          inputs.home-manager.nixosModules.home-manager
        ] ++ (mapModulesRec' (toString ../modules/system) import);
        environment.variables.NIXPKGS_ALLOW_UNFREE = "1";
        nix =
          let
            filteredInputs = filterAttrs (n: _: n != "self") inputs;
            nixPathInputs = mapAttrsToList (n: v: "${n}=${v}") filteredInputs;
            registryInputs = mapAttrs (_: v: { flake = v; }) filteredInputs;
          in
          {
            package = pkgs.nixVersions.stable;
            extraOptions = "experimental-features = nix-command flakes ca-derivations";
            nixPath = nixPathInputs ++ [
              "nixpkgs-overlays=${builtins.toString ../overlays}"
              "dotfiles=${builtins.toString ../.}"
            ];
            registry = registryInputs // {
              dotfiles.flake = inputs.self;
            };
            settings = {
              allowed-users = [ "@wheel" ];
              trusted-users = [
                "root"
                "@wheel"
              ];
              auto-optimise-store = true;
              warn-dirty = false;
              flake-registry = ""; # Disable global flake registry
              substituters = [ "https://hyprland.cachix.org" ];
              trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
            };
            gc = {
              automatic = true;
              dates = "weekly";
              options = "--delete-old";
            };

          };
        system.configurationRevision = with inputs; mkIf (self ? rev) self.rev;
        system.stateVersion = stateVersion;

        boot.tmp.cleanOnBoot = true;
        nixpkgs.hostPlatform = system;

        networking.useDHCP = mkDefault true;
        networking.networkmanager.enable = mkDefault false;
        hardware.enableRedistributableFirmware = mkDefault true;

        # Increase open file limit for sudoers
        security.pam.loginLimits = [
          {
            domain = "@wheel";
            item = "nofile";
            type = "soft";
            value = "524288";
          }
          {
            domain = "@wheel";
            item = "nofile";
            type = "hard";
            value = "1048576";
          }
        ];

        boot = {
          kernelPackages = mkDefault pkgs.linuxPackages_latest;
          loader = {
            efi.canTouchEfiVariables = mkDefault true;
          };
        };

        environment.systemPackages = with pkgs; [
          nix
          git
          nano
          wget
          gnumake
          unzip
          home-manager

          openssl
          sops
          ssh-to-age
          gnupg
          age
        ];

        home-manager.useUserPackages = mkDefault true;
        home-manager.useGlobalPkgs = mkDefault true;
        home-manager.extraSpecialArgs = {
          inherit lib' inputs;
        };
        home-manager.sharedModules = (mapModulesRec' (toString ../modules/home) import);

        # Since I am decoupling nix from home manager I don't need it I suppose
        # my.home =
        #   { ... }:
        #   {
        #     nixpkgs.config = pkgs.config;
        #     nixpkgs.overlays = pkgs.overlays;
        #     my.nixGL.enable = false; # we are on NixOS and should not need nixGL
        #   };
      };
    in
    nixosSystem {
      inherit system;
      specialArgs = {
        inherit
          lib
          inputs
          system
          lib'
          ;
      };
      modules = [
        {
          nixpkgs.pkgs = pkgs;
          networking.hostName = mkDefault (removeSuffix ".nix" (baseNameOf path));
        }
        (filterAttrs (
          n: v:
          !elem n [
            "system"
            "stateVersion"
          ]
        ) attrs)
        defaults
        (import path)
      ];
    };

  mapHosts = args: mapModules ../hosts (path: mkHost path args);
}
