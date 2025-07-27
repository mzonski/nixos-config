{
  delib,
  host,
  ...
}:
delib.module {
  name = "dconf";

  options = delib.singleEnableOption host.isDesktop;

  nixos.ifEnabled.programs.dconf.enable = true;
}
