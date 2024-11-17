{ pkgs, ... }:
{
  home.packages = (
    with pkgs;
    [
      bleachbit # Program to clean your computer
    ]
  );
}
