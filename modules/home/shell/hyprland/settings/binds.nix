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
  enabled = config.hom.shell.hyprland.enable;
  cfg = config.hom.shell.hyprland;

  mouseEventBinds = [
    "$mainMod, mouse:272, movewindow"
    "$mainMod, mouse:273, resizewindow"
  ];

  workspaceNavigation = [
    "$mainMod, mouse_up, workspace, e+1"
    "$mainMod, mouse_down, workspace, e-1"

    "$mainMod, 1, workspace, 1"
    "$mainMod, 2, workspace, 2"
    "$mainMod, 3, workspace, 3"
    "$mainMod, 4, workspace, 4"
    "$mainMod, 5, workspace, 5"
    "$mainMod, 6, workspace, 6"
    "$mainMod, 7, workspace, 7"
    "$mainMod, 8, workspace, 8"
    "$mainMod, 9, workspace, 9"
    "$mainMod, 0, workspace, 10"

    # same as above, but switch to the workspace
    "$mainMod SHIFT, 1, movetoworkspacesilent, 1" # movetoworkspacesilent
    "$mainMod SHIFT, 2, movetoworkspacesilent, 2"
    "$mainMod SHIFT, 3, movetoworkspacesilent, 3"
    "$mainMod SHIFT, 4, movetoworkspacesilent, 4"
    "$mainMod SHIFT, 5, movetoworkspacesilent, 5"
    "$mainMod SHIFT, 6, movetoworkspacesilent, 6"
    "$mainMod SHIFT, 7, movetoworkspacesilent, 7"
    "$mainMod SHIFT, 8, movetoworkspacesilent, 8"
    "$mainMod SHIFT, 9, movetoworkspacesilent, 9"
    "$mainMod SHIFT, 0, movetoworkspacesilent, 10"
    "$mainMod CTRL, c, movetoworkspace, empty"
  ];

  terminalLauncher = [
    "$mainMod, Return, exec, kitty"
    "$mainMod ALT, Return, exec, kitty --title float_kitty"
    "$mainMod SHIFT, Return, exec, kitty --start-as=fullscreen -o 'font_size=16'"
  ];

  appLaunchers = [
    "$mainMod, B, exec, hyprctl dispatch exec '[workspace 1 silent] floorp'"
    "$mainMod, D, exec, fuzzel"
    "$mainMod, R, exec, rofi -show drun"
    "$mainMod, E, exec, pcmanfm"
    "$mainMod, C, exec, hyprpicker -a"
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
    ",XF86AudioRaiseVolume,exec, pamixer -i 2"
    ",XF86AudioLowerVolume,exec, pamixer -d 2"
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
  config = mkIf enabled {
    wayland.windowManager.hyprland.settings.bindm = mouseEventBinds;

    wayland.windowManager.hyprland.settings.bind =
      workspaceNavigation
      ++ moveWindowFocus
      ++ terminalLauncher
      ++ appLaunchers
      ++ windowControl.layout
      ++ windowControl.move
      ++ windowControl.resize
      ++ mediaControl
      ++ system;
  };
}
