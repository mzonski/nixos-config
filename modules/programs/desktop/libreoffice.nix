{
  delib,
  pkgs,
  host,
  ...
}:
delib.module {
  name = "programs.desktop.libreoffice";

  options = delib.singleEnableOption host.isDesktop;

  home.ifEnabled.home.packages = [ pkgs.libreoffice-fresh ];
}
