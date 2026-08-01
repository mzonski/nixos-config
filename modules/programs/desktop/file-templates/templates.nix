{ delib, homeconfig, ... }:
delib.module {
  name = "programs.desktop.file-templates";

  home.always = {
    home.file."${homeconfig.xdg.userDirs.templates}" = {
      source = ./source;
      recursive = true;
    };
  };
}
