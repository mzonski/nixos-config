# This file (and the global directory) holds config that i use on all hosts
{
  inputs,
  outputs,
  lib,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./fish.nix
    ./locale.nix
    ./nix.nix
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.extraSpecialArgs = {
    inherit inputs outputs;
  };

  nixpkgs = {
    # If you want to use overlays exported from other flakes:
    # neovim-nightly-overlay.overlays.default

    # Or define it inline, for example:
    # (final: prev: {
    #   hi = final.hello.overrideAttrs (oldAttrs: {
    #     patches = [ ./change-hello-to-hi.patch ];
    #   });
    # })
    overlays = [ ];
    config = {
      allowUnfree = true;
    };
  };

  # Fix for qt6 plugins
  # TODO: maybe upstream this?
  # environment.profileRelativeSessionVariables = {
  #   QT_PLUGIN_PATH = [ "/lib/qt-6/plugins" ];
  # };

  hardware.enableRedistributableFirmware = true;
  networking.domain = "local.zonni.pl";

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

  # Cleanup stuff included by default
  services.speechd.enable = lib.mkForce false;
}
