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

    fonts = {
      family = "FiraCode Nerd Font";
      sizes = {
        normal = "15px";
        large = "18px";
        icon = "20px";
      };
      weight = "bold";
    };

    spacing = {
      xs = "6px";
      sm = "9px";
      md = "15px";
      lg = "20px";
      xl = "30px";
    };

    layout = {
      opacity = "0.98";
      radius = "4px";
      transition = "all 200ms ease-in-out";
      shadow = "0 2px 4px rgba(0, 0, 0, 0.2)";
      shadowInset = "inset 0 2px 4px rgba(0, 0, 0, 0.2)";
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
