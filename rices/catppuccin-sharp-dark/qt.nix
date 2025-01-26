{
  lib,
  pkgs,
  delib,
  ...
}:
let
  inherit (lib.generators) toINI;
in
delib.rice {
  name = "catppuccin-sharp-dark";

  packages = with pkgs; [
    kdePackages.breeze-icons
    libsForQt5.qt5.qtbase
    qt6.qtbase
    qt6.qtwayland
    qt5.qtwayland
  ];

  home =
    { cfg, ... }:
    let
      qtConfig = {
        Appearance = {
          custom_palette = "false";
          icon_theme = cfg.icons.name;
          standard_dialogs = "xdgdesktopportal";
          style = "kvantum-dark";
        };

        Fonts = {
          fixed = "\"${cfg.fonts.monospace.name},${
            toString (cfg.fonts.monospace.size - 2)
          },-1,5,50,0,0,0,0,0,Regular\"";
          general = "\"${cfg.fonts.regular.name},${
            toString (cfg.fonts.regular.size - 4)
          },-1,5,29,0,0,0,0,0,Regular\"";
        };

        Interface = {
          activate_item_on_single_click = "1";
          buttonbox_layout = "0";
          cursor_flash_time = "1000";
          dialog_buttons_have_icons = "1";
          double_click_interval = "400";
          gui_effects = "@Invalid()";
          keyboard_scheme = "2";
          menus_have_icons = "true";
          show_shortcuts_in_context_menus = "true";
          stylesheets = "@Invalid()";
          toolbutton_style = "4";
          underline_shortcut = "1";
          wheel_scroll_lines = "3";
        };

        SettingsWindow = {
          geometry = "@ByteArray(\\x1\\xd9\\xd0\\xcb\\0\\x3\\0\\0\\0\\0\\t`\\0\\0\\0\\0\\0\\0\\fo\\0\\0\\x3[\\0\\0\\t`\\0\\0\\0\\0\\0\\0\\xf\\x9f\\0\\0\\x3k\\0\\0\\0\\0\\x2\\0\\0\\0\\x6@\\0\\0\\t`\\0\\0\\0\\0\\0\\0\\fo\\0\\0\\x3[)";
        };

        Troubleshooting = {
          force_raster_widgets = "1";
          ignored_applications = "@Invalid()";
        };
      };
    in
    {
      qt = {
        enable = true;
        platformTheme.name = "qtct";
      };

      xdg.configFile = {
        qt5ct = {
          target = "qt5ct/qt5ct.conf";
          text = toINI { } qtConfig;
        };

        qt6ct = {
          target = "qt6ct/qt6ct.conf";
          text = toINI { } qtConfig;
        };
      };
    };
}
