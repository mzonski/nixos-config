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
  enabled = config.hom.wayland-wm.panel.waybar.enable;

  commonSettings = {
    position = "top";
    layer = "top";

    clock = {
      calendar = {
        format = {
          today = "<span color='#b4befe'><b><u>{}</u></b></span>";
        };
      };
      format = "{:%H:%M}";
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
      format-ethernet = "󰕒 {bandwidthUpBits} 󰇚 {bandwidthDownBits}";
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
      format-bluetooth = "{volume}% {icon}";
      format-icons = {
        default = [
          " "
          " "
        ];
        # TODO: Differentiate between primary and secondary HDMI output
        # "alsa_output.pci-0000_00_1f.3.analog-stereo" = "󰓃";
        #"alsa_output.pci-0000_00_1f.3.analog-stereo-muted" = "  󰓃";
      };
      scroll-step = 5;
      on-click = "pamixer -t";
      on-click-right = "pavucontrol";
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
    "custom/notification" = {
      tooltip = false;
      format = "{icon} ";
      format-icons = {
        notification = "<span foreground='red'><sup></sup></span>  ";
        none = "  ";
        dnd-notification = "<span foreground='red'><sup></sup></span>  ";
        dnd-none = "  ";
        inhibited-notification = "<span foreground='red'><sup></sup></span>  ";
        inhibited-none = "  ";
        dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>  ";
        dnd-inhibited-none = "  ";
      };
      return-type = "json";
      exec-if = "which swaync-client";
      exec = "swaync-client -swb";
      on-click = "swaync-client -t -sw";
      on-click-right = "swaync-client -d -sw";
      escape = true;
    };

    idle_inhibitor = {
      format = "{icon}";
      rotate = 0;
      format-icons = {
        activated = "󰥔 ";
        deactivated = " ";
      };
    };

    "wlr/taskbar" = {
      format = "{icon}";
      icon-size = 32;
      icon-theme = "Numix-Circle"; # TODO: THEME
      tooltip-format = "{title}";
      on-click = "minimize-raise";
      on-click-middle = "close";
      ignore-list = [
        "Kitty"
      ];
      app_ids-mapping = {
        firefoxdeveloperedition = "firefox-developer-edition";
      };
      rewrite = {
        "Firefox Web Browser" = "Firefox";
        "Foot Server" = "Terminal";
      };

      bluetooth = {
        format = " {status}";
        format-connected = " {device_alias}";
        format-connected-battery = " {device_alias} {device_battery_percentage}%";
        # format-device-preference = [ "device1"  "device2" ]; # preference list deciding the displayed device
        tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
        tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
        tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
        tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
      };

      "group/hardware" = {
        orientation = "inherit";
        modules = [
          "cpu"
          "memory"
          "battery"
        ];
      };

      systemd-failed-units = {
        hide-on-ok = false; # Do not hide if there is zero failed units.
        format = "✗ {nr_failed}";
        format-ok = "✓";
        system = true; # Monitor failed systemwide units.
        user = false; # Ignore failed user units.
      };
    };

    privacy = {
      icon-spacing = 4;
      icon-size = 32;
      transition-duration = 250;
      modules = [
        {
          type = "screenshare";
          tooltip = true;
          tooltip-icon-size = 42;
        }
        {
          type = "audio-out";
          tooltip = true;
          tooltip-icon-size = 42;
        }
        {
          type = "audio-in";
          tooltip = true;
          tooltip-icon-size = 42;
        }
      ];
    };

    "custom/separator" = {
      format = "  ";
      interval = "once";
      tooltip = false;
    };

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
            "custom/separator"
            "wlr/taskbar"
          ];
          modules-center = [
            "idle_inhibitor"
            "clock"
            "privacy"
          ];
          modules-right = [
            #"group/hardware"
            #"systemd-failed-units"

            #"bluetooth"
            "tray"
            "pulseaudio"
            #"battery"
            "custom/notification"
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
          modules-left = [
            "hyprland/workspaces"
            "custom/separator"
            "wlr/taskbar"
          ];
          modules-center = [ ];
          modules-right = [
            "cpu"
            "memory"
            "disk"
            "network"
          ];
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
