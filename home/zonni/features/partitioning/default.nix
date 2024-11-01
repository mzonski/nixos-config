{ pkgs, ... }:
{
  home.packages = (
    with pkgs;
    [
      fwupd
    ]
  );
}
