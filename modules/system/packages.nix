{ lib, pkgs, ... }:

with lib;
{
  config = {
    environment.systemPackages = with pkgs; [
      bash
      curl
      gnumake
    ];
  };
}
