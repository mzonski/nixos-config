{ pkgs, ... }:
{
  home.packages = (
    with pkgs;
    [
      qdirstat
    ]
  );
}
