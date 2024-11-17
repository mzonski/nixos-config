{
  catppuccin = {
    enable = true;
    flavor = "mocha";
    pointerCursor.enable = false;
    pointerCursor.flavor = "mocha";
  };
  qt.style.catppuccin.enable = true;
  qt.style.catppuccin.apply = true;
  programs.zsh.syntaxHighlighting.catppuccin.enable = true;
  gtk.catppuccin = {
    enable = false;
    gnomeShellTheme = false;

    icon.enable = false;

    tweaks = [ "normal" ];
  };
  programs.fish.catppuccin.enable = true;
}
