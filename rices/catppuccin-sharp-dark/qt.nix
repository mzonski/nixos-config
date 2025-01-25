# {
#   config,
#   lib,
#   pkgs,
#   ...
# }:
# let
#   inherit (lib) mkIf;
#   inherit (lib.generators) toINI;
#   inherit (config.hom.theme) fontProfiles;

#   enabled = config.qt.enable;

#   qtConfig = {
#     Appearance = {
#       custom_palette = "false";
#       icon_theme = config.gtk.iconTheme.name;
#       standard_dialogs = "xdgdesktopportal";
#       style = "kvantum-dark";
#     };

#     Fonts = {
#       fixed = "\"${fontProfiles.monospace.name},${
#         toString (fontProfiles.monospace.size - 2)
#       },-1,5,50,0,0,0,0,0,Regular\"";
#       general = "\"${fontProfiles.regular.name},${
#         toString (fontProfiles.regular.size - 4)
#       },-1,5,29,0,0,0,0,0,Regular\"";
#     };

#     Interface = {
#       activate_item_on_single_click = "1";
#       buttonbox_layout = "0";
#       cursor_flash_time = "1000";
#       dialog_buttons_have_icons = "1";
#       double_click_interval = "400";
#       gui_effects = "@Invalid()";
#       keyboard_scheme = "2";
#       menus_have_icons = "true";
#       show_shortcuts_in_context_menus = "true";
#       stylesheets = "@Invalid()";
#       toolbutton_style = "4";
#       underline_shortcut = "1";
#       wheel_scroll_lines = "3";
#     };

#     SettingsWindow = {
#       geometry = "@ByteArray(\\x1\\xd9\\xd0\\xcb\\0\\x3\\0\\0\\0\\0\\t`\\0\\0\\0\\0\\0\\0\\fo\\0\\0\\x3[\\0\\0\\t`\\0\\0\\0\\0\\0\\0\\xf\\x9f\\0\\0\\x3k\\0\\0\\0\\0\\x2\\0\\0\\0\\x6@\\0\\0\\t`\\0\\0\\0\\0\\0\\0\\fo\\0\\0\\x3[)";
#     };

#     Troubleshooting = {
#       force_raster_widgets = "1";
#       ignored_applications = "@Invalid()";
#     };
#   };
# in
# {
#   config = mkIf enabled {
#     home.packages = with pkgs; [
#       kdePackages.breeze-icons
#       libsForQt5.qt5.qtbase
#       qt6.qtbase
#       qt6.qtwayland
#       qt5.qtwayland
#     ];

#     qt = {
#       platformTheme.name = "qtct";
#     };

#     xdg.configFile = {
#       qt5ct = {
#         target = "qt5ct/qt5ct.conf";
#         text = toINI { } qtConfig;
#       };

#       qt6ct = {
#         target = "qt6ct/qt6ct.conf";
#         text = toINI { } qtConfig;
#       };
#     };
#   };
# }
{ }
