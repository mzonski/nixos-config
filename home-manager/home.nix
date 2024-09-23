# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  # You can import other home-manager modules here
  imports = [
    #./vscode.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "zonni";
    homeDirectory = "/home/zonni";
    packages = with pkgs; [
      hello
      vscode
      cowsay
      nixfmt-rfc-style
      nil
    ];
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

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
    ];
    userSettings = {
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
    };
    keybindings = [
      {
        key = "ctrl+alt+l";
        command = "editor.action.formatDocument";
        when = "editorHasDocumentFormattingProvider && editorTextFocus && !editorReadonly";
      }
    ];
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
