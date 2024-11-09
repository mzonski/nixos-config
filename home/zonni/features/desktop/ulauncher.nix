{ pkgs, ... }:
{
  home.packages = (
    with pkgs;
    [
      ulauncher
    ]
  );
}
