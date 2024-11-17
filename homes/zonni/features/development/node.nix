{ pkgs, ... }:
{
  programs.poetry.enable = true;

  home.packages = (
    with pkgs;
    [
      nodejs_20
      node-gyp
      node-glob
    ]
  );
}
