{ delib, pkgs, ... }:
delib.module {
  name = "programs.packages";
  nixos.always = {
    environment.systemPackages = with pkgs; [
      bash
      curl
      gnumake
      screen
      unstable.msedit

      coreutils-full

      nix
      git
      gh
      nano
      wget
      unzip

      openssl
      age
      ssh-to-age

      lsof
      psmisc
    ];
  };
}
