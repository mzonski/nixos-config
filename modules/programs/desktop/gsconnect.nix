{
  delib,
  pkgs,
  lib,
  ...
}:

let
  inherit (delib) module singleEnableOption;
  inherit (lib) mkIf;
in
module {
  name = "programs.gsconnect";

  options = singleEnableOption false;

  myconfig.ifEnabled =
    { myconfig, ... }:
    {
      programs.gnome.extensions = mkIf myconfig.programs.gnome.enable [ pkgs.gnomeExtensions.gsconnect ];
      programs.firefox.navBarEntries = mkIf myconfig.programs.firefox.enable [
        "gsconnect_andyholmes_github_io-browser-action"
      ];

      xdg.mime.recommended =
        let
          launcher = "org.gnome.Shell.Extensions.GSConnect.desktop";
        in
        {
          "x-scheme-handler/sms" = [ launcher ];
          "x-scheme-handler/tel" = [ launcher ];
        };
    };

  nixos.ifEnabled.networking.firewall.allowedTCPPorts = [ 1716 ];

  home.ifEnabled =
    { myconfig, ... }:
    {
      programs.firefox = mkIf myconfig.programs.firefox.enable {
        nativeMessagingHosts = [ pkgs.gnomeExtensions.gsconnect ];
        profiles.default = {
          extensions.packages = [
            pkgs.firefoxAddons.gsconnect
          ];
        };
      };
    };
}
