{ pkgs, ... }:
{
  home.packages = (
    with pkgs;
    [
      peazip
    ]
  );
}
