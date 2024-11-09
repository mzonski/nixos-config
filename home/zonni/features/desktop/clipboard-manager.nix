{ pkgs, ... }:
{
  home.packages = (
    with pkgs;
    [
      copyq
    ]
  );
}
