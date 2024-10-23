{ config, pkgs, ... }:
{
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
    ];
    userSettings = {
      mutableExtensionsDir = false;
      enableExtensionUpdateCheck = false;
      enableUpdateCheck = false;
      editor = {
        formatOnSave = true;
        defaultFormatter = "esbenp.prettier-vscode";
      };
      "[nix]".editor = {
        formatOnSave = true;
        defaultFormatter = "jnoortheen.nix-ide";
      };
      files.autoSave = "onFocusChange";
      workbench.colorTheme = "Default Dark+";
      editor.minimap.enabled = false;
      nixEnvSelector.nixFile = "${config.home.homeDirectory}/Projects/nixos-config/flake.nix";
      prettier.configPath = ".prettierrc";

      nix.enableLanguageServer = true;
      nix.serverPath = "nil";
      nix.formatterPath = "nixfmt";
      nix.serverSettings.nil.formatting.command = [ "nixfmt" ];

      git.autofetch = true;
      makefile.configureOnOpen = false;
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
