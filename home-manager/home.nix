{
  _inputs,
  _lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./git.nix
    ./vscode.nix
  ];

  nixpkgs = {
    # You can add overlays here
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
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "zonni";
    homeDirectory = "/home/zonni";
    packages = with pkgs; [
      vscode
      cowsay
      nixfmt-rfc-style
      nil
      python312
      python312Packages.pip
    ];

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "24.05";
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.poetry.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
