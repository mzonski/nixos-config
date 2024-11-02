{
  lib,
  config,
  pkgs,
  outputs,
  ...
}:
{
  imports = [
    ./features/cli
    ./features/desktop
    ./features/development
    ./features/partitioning
  ] ++ (builtins.attrValues outputs.homeManagerModules);

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "ca-derivations"
      ];
      warn-dirty = false;
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  news.display = "silent";

  systemd.user.startServices = "sd-switch";

  programs = {
    home-manager.enable = true;
  };

  home = {
    username = lib.mkDefault "zonni";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "24.11";
    sessionPath = [ "$HOME/.local/bin" ];
    sessionVariables = {
      FLAKE = "$HOME/Git/nixos-config";
      EDITOR = "nano"; # or your preferred editor
      SHELL = "${pkgs.zsh}/bin/zsh";
    };
  };
}
