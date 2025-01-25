{ delib, pkgs, ... }:
delib.module {
  name = "toplevel.packages";
  nixos.always = {
    environment.systemPackages = with pkgs; [
      bash
      curl
      gnumake

      nix
      git
      nano
      wget
      unzip

      openssl
      age
    ];
  };
}
