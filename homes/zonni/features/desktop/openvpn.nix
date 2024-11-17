{ pkgs, ... }:
{
  home.packages = (
    with pkgs;
    [
      openvpn
      openvpn3
    ]
  );
}
