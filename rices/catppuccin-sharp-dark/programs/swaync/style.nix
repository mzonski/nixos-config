{ delib, ... }:
delib.rice {
  name = "catppuccin-sharp-dark";

  home.services.swaync.style = builtins.readFile ./style.css;
}
