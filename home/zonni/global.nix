{
  lib,
  config,
  ...
}:
{
  imports = [
    ./features/cli
  ];

  systemd.user.startServices = "sd-switch";

  nixpkgs = {
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    config.allowUnfree = true;
  };

  programs = {
    home-manager.enable = true;
  };

  home = {
    username = lib.mkDefault "zonni";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "24.05";
    sessionPath = [ "$HOME/.local/bin" ];
    sessionVariables = {
      FLAKE = "$HOME/Projects/nixos-config";
    };
  };
}
