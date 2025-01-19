{
  config,
  lib,
  pkgs,
  lib',
  ...
}:

with lib;
with lib';
let
  cfg = config.hom.development.vscode;
  hyprlandEnabled = config.hom.wayland-wm.hyprland.enable;
  fontProfiles = config.hom.theme.fontProfiles;
in
{
  options.hom.development.vscode = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {

    home.packages = (
      with pkgs;
      [
        unstable.vscodium

        nil # Nix LSP
        nixfmt-rfc-style # Nix formatter
        nvd # Differ
        nix-diff # Differ, more detailed
        nix-output-monitor
      ]
    );

    programs.vscode = {
      enable = true;
      package = pkgs.unstable.vscodium;
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
        jnoortheen.nix-ide
        arrterian.nix-env-selector
        esbenp.prettier-vscode
        k--kato.intellij-idea-keybindings
        ms-vscode.makefile-tools
        eamodio.gitlens
        catppuccin.catppuccin-vsc
        catppuccin.catppuccin-vsc-icons
      ];
      userSettings = {
        mutableExtensionsDir = false;
        enableExtensionUpdateCheck = false;
        enableUpdateCheck = false;
        editor = {
          formatOnSave = true;
          semanticHighlighting.enabled = true; # // we try to make semantic highlighting look good
          defaultFormatter = "esbenp.prettier-vscode";
        };
        "[nix]".editor = {
          formatOnSave = true;
          defaultFormatter = "jnoortheen.nix-ide";
        };
        files.autoSave = "onFocusChange";
        editor.minimap.enabled = false;
        nixEnvSelector.nixFile = "${config.home.homeDirectory}/Projects/nixos-config/flake.nix";
        prettier.configPath = ".prettierrc";

        nix.enableLanguageServer = true;
        nix.serverPath = "nil";
        nix.formatterPath = "nixfmt";
        nix.serverSettings.nil.formatting.command = [ "nixfmt" ];
        # TODO: Remove this frikin message -_-
        # nix.hiddenLanguageServerErrors = [ "Request textDocument/formatting failed." ];

        git.autofetch = true;
        makefile.configureOnOpen = false;

        "editor.fontFamily" =
          if fontProfiles.enable then
            "${fontProfiles.monospace.name}, 'Droid Sans Mono', 'monospace', monospace"
          else
            "'Droid Sans Mono', 'monospace', monospace";

        "workbench.colorTheme" = "Catppuccin Mocha";
        "workbench.iconTheme" = "catppuccin-mocha";
        terminal.integrated.minimumContrastRatio = 1; # prevent VSCode from modifying the terminal colors
        window.titleBarStyle = if hyprlandEnabled then "native" else "custom";

        "catppuccin.customUIColors".mocha."statusBar.foreground" = "accent";
      };
      keybindings = [
        {
          key = "ctrl+alt+l";
          command = "editor.action.formatDocument";
          when = "editorHasDocumentFormattingProvider && editorTextFocus && !editorReadonly";
        }
      ];
    };
  };
}
