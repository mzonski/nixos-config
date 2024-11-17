{ config, pkgs, ... }:
{
  home.packages = (
    with pkgs;
    [
      vscode
      nixfmt-rfc-style
      nil
    ]
  );

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
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

      git.autofetch = true;
      makefile.configureOnOpen = false;

      "workbench.colorTheme" = "Catppuccin Mocha";
      "workbench.iconTheme" = "catppuccin-mocha";
      terminal.integrated.minimumContrastRatio = 1; # prevent VSCode from modifying the terminal colors
      window.titleBarStyle = "custom"; # make the window's titlebar use the workbench colors

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
}
