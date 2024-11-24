{
  inputs,
  config,
  options,
  lib,
  pkgs,
  mylib,
  ...
}:

with lib;
with mylib;
let
  enabled = config.hom.shell.panel.waybar.enable;

  commonSettings = {
    position = "top";
    layer = "top";

    clock = {
      calendar = {
        format = {
          today = "<span color='#b4befe'><b><u>{}</u></b></span>";
        };
      };
      format = " {:%H:%M}";
      format-alt = " {:%d/%m/%Y}";
      tooltip = "true";
      tooltip-format = "<tt><big>{calendar}</big></tt>";

    };
    "hyprland/workspaces" = {
      active-only = false;
      disable-scroll = true;
      format = "{icon}";
      on-click = "activate";
      format-icons = {
        "1" = "";
        "2" = "󰈹";
        "3" = "";
        "4" = "󰘙";
        "5" = "";
        "6" = "";
        "7" = "";
        "8" = "";
        urgent = "";
        default = "";
        sort-by-number = true;
      };
    };
    memory = {
      format = "󰟜 {}%";
      format-alt = "󰟜 {used} GiB";
      interval = 2;
    };

    disk = {
      # path = "/";
      format = "󰋊 {percentage_used}%";
      interval = 60;
    };
    network = {
      format-wifi = "  {signalStrength}%";
      format-ethernet = "󰀂 {bandwidthUpBits} 󰁝 {bandwidthDownBits}";
      format-linked = "{ifname} (No IP)";
      format-disconnected = "󰖪 ";
      tooltip = true;
      tooltip-format = ''
        󰢮 Connection Status:
        ├─ 󰌗 Interface: {ifname}
        ├─ 󰩟 IP: {ipaddr}
        ├─ 󰖟 Gateway: {gwaddr}
        ├─ 󰕒 Upload: {bandwidthUpBits}
        └─ 󰇚 Download: {bandwidthDownBits}
      '';
      tooltip-format-disconnected = "Disconnected";
    };
    tray = {
      icon-size = 28;
      spacing = 8;
    };
    pulseaudio = {
      format = "{icon} {volume}%";
      format-muted = "  {volume}%";
      format-icons = {
        default = [ " " ];
      };
      scroll-step = 5;
      on-click = "pamixer -t";
    };

    cpu = {
      format = " {usage}%";
      interval = 2;
    };
    "custom/launcher" = {
      format = "   ";
      on-click = "rofi -show drun";
      tooltip = false;
    };
    # battery = {
    #   format = "{icon} {capacity}%";
    #   format-icons = [
    #     " "
    #     " "
    #     " "
    #     " "
    #     " "
    #   ];
    #   format-charging = " {capacity}%";
    #   format-full = " {capacity}%";
    #   format-warning = " {capacity}%";
    #   interval = 5;
    #   states = {
    #     warning = 20;
    #   };
    #   format-time = "{H}h{M}m";
    #   tooltip = true;
    #   tooltip-format = "{time}";
    # };
    # "custom/notification" = {
    #   tooltip = false;
    #   format = "{icon} ";
    #   format-icons = {
    #     notification = "<span foreground='red'><sup></sup></span>   ";
    #     none = "   ";
    #     dnd-notification = "<span foreground='red'><sup></sup></span>   ";
    #     dnd-none = "   ";
    #     inhibited-notification = "<span foreground='red'><sup></sup></span>   ";
    #     inhibited-none = "   ";
    #     dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>   ";
    #     dnd-inhibited-none = "   ";
    #   };
    #   return-type = "json";
    #   exec-if = "which swaync-client";
    #   exec = "swaync-client -swb";
    #   on-click = "swaync-client -t -sw";
    #   on-click-right = "swaync-client -d -sw";
    #   escape = true;
    # };

  };
in
{
  config = mkIf enabled {
    programs.waybar.settings = [
      (
        commonSettings
        // {
          output = "DP-4";
          modules-left = [
            "custom/launcher"
            "hyprland/workspaces"
          ];
          modules-center = [ "clock" ];
          modules-right = [
            "tray"
            "cpu"
            "memory"
            "disk"
            "pulseaudio"
            #"battery"
            "network"
            #"custom/notification"
          ];
          "hyprland/workspaces" = commonSettings."hyprland/workspaces" // {
            persistent-workspaces = {
              "1" = [ ];
              "2" = [ ];
              "3" = [ ];
              "4" = [ ];
            };
          };
        }
      )
      (
        commonSettings
        // {
          output = "HDMI-A-4";
          modules-left = [ "hyprland/workspaces" ];
          modules-center = [ "clock" ];
          modules-right = [ ];
          "hyprland/workspaces" = commonSettings."hyprland/workspaces" // {
            persistent-workspaces = {
              "5" = [ ];
              "6" = [ ];
              "7" = [ ];
              "8" = [ ];
            };
          };
        }
      )
    ];
  };
}
