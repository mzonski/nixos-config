{ lib, pkgs, ... }:

with lib;
{
  config = {
    environment.systemPackages = with pkgs; [
      curl
      gnumake
    ];
  };
}
