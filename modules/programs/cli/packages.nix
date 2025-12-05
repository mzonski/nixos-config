{
  delib,
  pkgs,
  ...
}:
delib.module {
  name = "programs.cli.packages";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    home.packages = with pkgs; [
      bottom # System viewer (btm)
      btop # Better top
      ncdu # Calculates space usage of files
      fd # Better find
      jq # JSON pretty printer and manipulator
      powertop # check energy consumption per program
      tldr # quick man

      tcpdump
      dig # DNS lookup utility
    ];
  };
}
