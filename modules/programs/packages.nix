{ delib, pkgs, ... }:
delib.module {
  name = "programs.packages";
  nixos.always = {
    environment.systemPackages = with pkgs; [
      bash
      curl
      gnumake
      screen

      nix
      git
      gh
      nano
      wget
      unzip

      openssl
      age

      lsof
      psmisc
    ];
  };
}
