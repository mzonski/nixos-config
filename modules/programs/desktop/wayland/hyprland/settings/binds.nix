{ delib, lib, ... }:
let
  inherit (lib) concatLists;
  inherit (delib) module;
in
module {
  name = "programs.wayland";

  home.ifEnabled =
    { myconfig, ... }:
    let
      cmds = myconfig.commands;

      variables = {
        "$mainMod" = "SUPER";
        "$shiftMod" = "SUPER_SHIFT";
        "$ctrlMod" = "SUPER_CTRL";
        "$altMod" = "SUPER_ALT";

        "$mouseLeft" = "mouse:272";
        "$mouseRight" = "mouse:273";
        "$mouseMiddle" = "mouse:274";
        "$mouseForward" = "mouse:275";
        "$mouseBack" = "mouse:276";
        "$mouseWheelUp" = "mouse:278";
        "$mouseWheelDown" = "mouse:279";
      };

      mouseEventBinds = [
        "$mainMod, $mouseLeft, movewindow" # Move windows
        "$mainMod, $mouseRight, resizewindow" # Resize windows
      ];

      mouseWorkspaceNavigation = [
        "$mainMod, $mouseForward, workspace, e+1" # Next workspace
        "$mainMod, $mouseBack, workspace, e-1" # Previous workspace

        "$mainMod, $mouseMiddle, togglefloating" # Toggle window floating state

        # Window state management
        "$shiftMod, $mouseLeft, togglegroup" # Toggle window grouping
        "$shiftMod, $mouseRight, pin" # Pin window
        "$shiftMod, $mouseMiddle, pseudo" # Toggle pseudo mode

        #"$altMod, $mouseLeft, swapnext" # Swap with next window
        #"$altMod, $mouseRight, swapprev" # Swap with previous window
        "$altMod, $mouseMiddle, centerwindow" # Center window

        # Advanced window management
        # "$ctrlMod, $mouseLeft, fullscreen, 1" # Toggle fullscreen (preserves workspaces)
        "$ctrlMod, $mouseLeft, movetoworkspace, special" # Move a window/application to a special workspace
        "$ctrlMod, $mouseRight, fullscreen, 0" # Toggle fullscreen (no workspaces)
        "$ctrlMod, $mouseMiddle, togglesplit" # Toggle split

        #"$shiftMod, $mouseWheelUp, changegroupactive, f" # Next window in group
        #"$shiftMod, $mouseWheelDown, changegroupactive, b" # Previous window in group

      ];

      workspaceNavigation = [

        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, grave, movetoworkspace, empty"

        "$mainMod CTRL, 1, workspace, 5"
        "$mainMod CTRL, 2, workspace, 6"
        "$mainMod CTRL, 3, workspace, 7"
        "$mainMod CTRL, 4, workspace, 8"

        # send window to other workspace
        "$mainMod SHIFT, 1, movetoworkspacesilent, 1"
        "$mainMod SHIFT, 2, movetoworkspacesilent, 2"
        "$mainMod SHIFT, 3, movetoworkspacesilent, 3"
        "$mainMod SHIFT, 4, movetoworkspacesilent, 4"
        "$mainMod SHIFT, 5, movetoworkspacesilent, 5"
        "$mainMod SHIFT, 6, movetoworkspacesilent, 6"
        "$mainMod SHIFT, 7, movetoworkspacesilent, 7"
        "$mainMod SHIFT, 8, movetoworkspacesilent, 8"
      ];

      terminalLauncher = [
        "$mainMod, Return, exec, ${cmds.runTerminal}"
        "$mainMod ALT, Return, exec, ${cmds.runTerminal} --title float_kitty"
        "$mainMod SHIFT, Return, exec, ${cmds.runTerminal} --start-as=fullscreen -o 'font_size=16'"
      ];

      appLaunchers = [
        "$mainMod, R, exec, ${cmds.runDrun}"
        "$mainMod, E, exec, ${cmds.runFileManager}"
        "$mainMod, C, exec, ${cmds.runColorPicker}"
        "$mainMod, V, exec, ${cmds.runClipboardHistory}"
        ", Print, exec, ${cmds.captureWholeScreen}"
        "ALT, Print, exec, ${cmds.captureArea}"
      ];

      windowControl = {
        layout = [
          "$mainMod, Q, killactive,"
          "$mainMod, F, fullscreen, 0"
          "$mainMod SHIFT, F, fullscreen, 1"
          "$mainMod, Space, togglefloating,"
          "$mainMod, P, pseudo,"
          "$mainMod, J, togglesplit,"
        ];
        move = [
          "$mainMod SHIFT, left, movewindow, l"
          "$mainMod SHIFT, right, movewindow, r"
          "$mainMod SHIFT, up, movewindow, u"
          "$mainMod SHIFT, down, movewindow, d"
        ];
        resize = [
          "$mainMod SHIFT, left, movewindow, l"
          "$mainMod SHIFT, right, movewindow, r"
          "$mainMod SHIFT, up, movewindow, u"
          "$mainMod SHIFT, down, movewindow, d"
          "$mainMod CTRL, left, resizeactive, -80 0"
          "$mainMod CTRL, right, resizeactive, 80 0"
          "$mainMod CTRL, up, resizeactive, 0 -80"
          "$mainMod CTRL, down, resizeactive, 0 80"
          "$mainMod ALT, left, moveactive,  -80 0"
          "$mainMod ALT, right, moveactive, 80 0"
          "$mainMod ALT, up, moveactive, 0 -80"
          "$mainMod ALT, down, moveactive, 0 80"
        ];
      };

      moveWindowFocus = [
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
      ];

      system = [
        "$mainMod, Escape, exec, swaylock"
      ];

      mediaControl = [
        ",XF86AudioRaiseVolume,exec, pamixer -i 10"
        ",XF86AudioLowerVolume,exec, pamixer -d 10"
        ",XF86AudioMute,exec, pamixer -t"
        ",XF86AudioPlay,exec, playerctl play-pause"
        ",XF86AudioNext,exec, playerctl next"
        ",XF86AudioPrev,exec, playerctl previous"
        ",XF86AudioStop, exec, playerctl stop"

        # laptop brigthness
        ",XF86MonBrightnessUp, exec, brightnessctl set 5%+"
        ",XF86MonBrightnessDown, exec, brightnessctl set 5%-"
        "$mainMod, XF86MonBrightnessUp, exec, brightnessctl set 100%+"
        "$mainMod, XF86MonBrightnessDown, exec, brightnessctl set 100%-"
      ];
    in
    {
      wayland.windowManager.hyprland.settings.general = variables;
      wayland.windowManager.hyprland.settings.bindm = mouseEventBinds;

      wayland.windowManager.hyprland.settings.bind = concatLists [
        mouseWorkspaceNavigation
        workspaceNavigation
        moveWindowFocus
        terminalLauncher
        appLaunchers
        windowControl.layout
        windowControl.move
        windowControl.resize
        mediaControl
        system
      ];

    };
}
