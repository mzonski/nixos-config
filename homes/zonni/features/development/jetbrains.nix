{ pkgs, ... }:
{
  home.packages = (
    with pkgs;
    [
      jetbrains.pycharm-professional
      jetbrains.datagrip
      jetbrains.webstorm
    ]
  );
}
