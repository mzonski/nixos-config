{ pkgs, ... }:
{
  home.packages = (
    with pkgs;
    [
      flameshot
    ]
  );
}
