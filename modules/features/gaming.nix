{ delib, pkgs, ... }:

let
  inherit (delib) module singleEnableOption;
in
module {
  name = "features.gaming";

  options = singleEnableOption false;

  nixos.ifEnabled = {
    programs.steam.enable = true;
    programs.gamemode.enable = true;

    environment.sessionVariables = {
      STEAM_FORCE_DESKTOPUI_SCALING = "1.6";
    };

    environment.systemPackages = with pkgs; [
      # Steam
      mangohud
      gamemode
      # WINE
      wine
      winetricks
      protontricks
      vulkan-tools
      protonup-qt
      # Extra dependencies
      # https://github.com/lutris/docs/
      gnutls
      openldap
      libgpg-error
      freetype
      sqlite
      libxml2
      xml2
      SDL2
    ];
  };
}
