{
  delib,
  lib,
  pkgs,
  ...
}:
let
  inherit (delib) module boolOption;
  inherit (lib) mkIf;
in
module {
  name = "programs.gnome";

  options.programs.gnome = {
    enable = boolOption false;
    fullInstall = boolOption false;
    noUserSessionFreeze.enable = boolOption false;
    freezeOnNvidiaSuspend.enable = boolOption false;
  };

  myconfig.ifEnabled = {
    programs.gdm.enable = true;
  };

  nixos.ifEnabled =
    { cfg, ... }:
    {
      services.xserver.enable = true;
      services.xserver.desktopManager.gnome.enable = true;

      services.gnome = mkIf cfg.fullInstall {
        core-os-services.enable = true;
        core-shell.enable = true;
        core-utilities.enable = true;
        core-developer-tools.enable = true;
        games.enable = false;
      };
    };

  home.ifEnabled =
    { cfg, myconfig, ... }:
    let
      inherit (lib.gvariant) mkTuple;
    in
    {
      home.packages = with pkgs; [
        dconf-editor
        pkgs.kdePackages.ocean-sound-theme
      ];

      dconf = {
        enable = true;
        settings = {
          "org/gnome/gnome-session" = {
            auto-save-session = true;
          };
          "org/gnome/desktop/peripherals/touchpad" = {
            tap-to-click = true;
            two-finger-scrolling-enabled = true;
          };
          "org/gnome/desktop/calendar" = {
            show-weekdate = true;
            two-finger-scrolling-enabled = true;
          };
          "org/gnome/desktop/sound" = {
            allow-volume-above-100-percent = true;
            theme-name = "ocean";
            event-sounds = true;
            input-feedback-sounds = true;
          };
          "org/gnome/desktop/peripherals/mouse" = {
            middle-click-emulation = true;
          };
          "org/gnome/desktop/input-sources" = {
            current = "uint32 0";
            sources = [
              (mkTuple [
                "xkb"
                "pl"
              ])
            ];
            xkb-options = [ "terminate:ctrl_alt_bksp" ];
          };
          "org/gnome/mutter" = {
            edge-tiling = true;
            workspaces-only-on-primary = false;
            dynamic-workspaces = false;
            experimental-features = [ "scale-monitor-framebuffer" ];
          };

          "org/gnome/settings-daemon/plugins/color" = {
            night-light-enabled = false;
            night-light-temperature = 3500;
            night-light-schedule-automatic = true;
            night-light-last-coordinates = mkTuple [
              51.7673
              18.0853
            ];
          };
          "org/gnome/eog/ui" = {
            image-gallery = true;
          };

          "org/gnome/nautilus/icon-view" = {
            default-zoom-level = "small";
          };
        };
      };
    };
}
