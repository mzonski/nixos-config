{ pkgs, ... }:
{
  home.packages = (
    with pkgs;
    [
      qcad
    ]
  );
}
