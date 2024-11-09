{ pkgs, ... }:
{
  home.packages = (
    with pkgs;
    [
      openvpn3
    ]
  );
}
