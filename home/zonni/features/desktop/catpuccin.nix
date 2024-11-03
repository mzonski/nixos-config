{
  catppuccin = {
    enable = true;
    flavor = "mocha";
    pointerCursor.enable = false;
    pointerCursor.flavor = "mocha";
  };
  gtk.catppuccin = {
    enable = false;
    gnomeShellTheme = false;

    icon.enable = false;

    tweaks = [ "normal" ];
  };
  programs.fish.catppuccin.enable = true;
}
