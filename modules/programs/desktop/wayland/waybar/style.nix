{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf;

  enabled = config.hom.wayland-wm.panel.waybar.enable;

  # Theme configuration
  theme = {
    colors = {
      primary = "#cdd6f4";
      secondary = "#89b4fa";
      tertiary = "#f5f5f5";
      background = "#11111B";
      workspace = {
        active = "#b4befe";
        inactive = "#6c7086";
      };
      border = "#313244";
      warning = "#f9e2af";
      critical = "#f38ba8";
    };
  };

  # Generate SCSS variables from theme
  scssVars = ''
    // Colors
    $color-primary: ${theme.colors.primary};
    $color-secondary: ${theme.colors.secondary};
  '';

  # Write SCSS variables to a file
  scssVarsFile = pkgs.writeText "variables.scss" scssVars;

  # Compile SCSS to CSS using sass
  waybarCss =
    pkgs.runCommand "compile-waybar-styles.css"
      {
        buildInputs = [ pkgs.sass ];
      }
      ''
        # Create complete SCSS file by combining variables and styles
        cat ${scssVarsFile} ${./style.scss} > complete.scss

        # Compile SCSS to CSS (removed --no-source-map flag)
        sass complete.scss $out
      '';

in
{
  config = mkIf enabled {
    programs.waybar.style = builtins.readFile waybarCss + "\n\n @import './custom.css';";
  };
}
