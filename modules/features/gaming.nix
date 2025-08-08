{
  delib,
  lib,
  pkgs,
  homeconfig,
  ...
}:

let
  inherit (delib) module singleEnableOption;
  inherit (lib) optionalAttrs mkIf;
  inherit (homeconfig.lib.file) mkOutOfStoreSymlink;
in
module {
  name = "features.gaming";

  options = singleEnableOption false;

  nixos.ifEnabled = {

    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
      extraCompatPackages = with pkgs; [
        unstable.proton-ge-bin
      ];
    };

    programs.gamescope.enable = true;
    programs.gamescope.capSysNice = true;
    programs.gamemode.enable = true;

    hardware.xone.enable = true;

    environment.sessionVariables = {
      # STEAM_FORCE_DESKTOPUI_SCALING = "1.6";
    };

    environment.systemPackages = with pkgs; [
      # Steam
      unstable.mangohud
      # WINE
      unstable.wine
      unstable.winetricks
      unstable.protontricks
      unstable.vulkan-tools
      unstable.protonup-qt
      # Extra dependencies
      # https://github.com/lutris/docs/
      unstable.lutris
      unstable.gnutls
      unstable.openldap
      unstable.libgpg-error
      unstable.freetype
      unstable.sqlite
      unstable.libxml2
      unstable.xml2
      unstable.SDL2
      # GameBoy
      unstable.mgba
    ];

    #system.activationScripts.steamCompatDataLink = ''ln -s ~/.steam/steam/steamapps/compatdata /mnt/data/Steam/steamapps/'';
  };

  home.ifEnabled =
    { myconfig, ... }:
    let
      isWindowsParitionEnabled = myconfig.features.windows-data-partition.enable;
    in
    {
      home.file.".steam/steam/steamapps/compatdata/.keep".text = "";

      # # Create symlink - simple approach
      # home.file."/mnt/data/Steam/steamapps/compatdata".source =
      #   "${homeconfig.home.homeDirectory}/.steam/steam/steamapps/compatdata";

      #home.file = mkIf (isWindowsParitionEnabled) {
      #  ".steam/steam/steamapps/compatdata".source = mkOutOfStoreSymlink "/mnt/data/Steam/steamapps/";
      #};
      #home.file = mkIf (isWindowsParitionEnabled) {
      #  "/mnt/data/Steam/steamapps/compatdata".source =
      #    mkOutOfStoreSymlink "${homeconfig.home.homeDirectory}/.steam/steam/steamapps/compatdata";
      #};
    };
}
