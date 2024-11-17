{
  inputs,
  lib,
  mylib,
  pkgs,
  ...
}:

with lib;
with mylib;
let
  sys = "x86_64-linux";
  defaults = {
    imports =
      # I use home-manager to deploy files to $HOME; little else
      [ inputs.home-manager.nixosModules.home-manager ]
      # All my personal modules
      ++ (mapModulesRec' (toString ../modules/system) import);

    # Configure nix and nixpkgs
    environment.variables.NIXPKGS_ALLOW_UNFREE = "1";
    nix =
      let
        filteredInputs = filterAttrs (n: _: n != "self") inputs;
        nixPathInputs = mapAttrsToList (n: v: "${n}=${v}") filteredInputs;
        registryInputs = mapAttrs (_: v: { flake = v; }) filteredInputs;
      in
      {
        package = pkgs.nixVersions.stable;
        extraOptions = "experimental-features = nix-command flakes";
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
        };
      };
    system.configurationRevision = with inputs; mkIf (self ? rev) self.rev;
    system.stateVersion = "24.11";

    ## Some reasonable, global defaults
    # This is here to appease 'nix flake check' for generic hosts with no
    # hardware-configuration.nix or fileSystem config.
    # fileSystems."/".device = mkDefault "/dev/disk/by-label/nixos";

    networking.useDHCP = mkDefault true;
    networking.networkmanager.enable = mkDefault false;

    # Use the latest kernel
    boot = {
      kernelPackages = mkDefault pkgs.linuxPackages_latest;
      loader = {
        efi.canTouchEfiVariables = mkDefault true;
      };
    };

    # Just the bear necessities...
    environment.systemPackages = with pkgs; [
      bind
      cached-nix-shell
      git
      micro
      wget
      gnumake
      unzip
    ];

    # We also want to load the relevant home profile and setup home-manager
    home-manager.extraSpecialArgs = {
      inherit mylib inputs;
    };
    home-manager.sharedModules = (mapModulesRec' (toString ../modules/home) import);
    # TODO: ENABLE "my"
    #my.home =
    #  { ... }:
    #  {
    #    nixpkgs.config = pkgs.config;
    #    nixpkgs.overlays = pkgs.overlays;
    #    my.nixGL.enable = false; # we are on NixOS and should not need nixGL
    #  };
  };
in
{
  mkHost =
    path:
    attrs@{
      system ? sys,
      ...
    }:
    nixosSystem {
      inherit system;
      specialArgs = {
        inherit
          lib
          inputs
          system
          mylib
          ;
      };
      modules = [
        {
          nixpkgs.pkgs = pkgs;
          networking.hostName = mkDefault (removeSuffix ".nix" (baseNameOf path));
        }
        (filterAttrs (n: v: !elem n [ "system" ]) attrs)
        defaults
        (import path)
      ];
    };

  mapHosts =
    dir:
    attrs@{
      system ? system,
      ...
    }:
    mapModules dir (hostPath: mkHost hostPath attrs);
}
