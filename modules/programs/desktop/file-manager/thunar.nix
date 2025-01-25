{
  config,
  lib,
  pkgs,
  lib',
  ...
}:

let
  enabled = config.programs.file-manager.app == "thunar";
  thunarPlugins = with pkgs.xfce; [
    thunar-volman
    thunar-archive-plugin
  ];
  inherit (lib') mkBoolOpt;
  inherit (lib) mkIf;
in
{
  options.programs.file-manager = {
    thunar = mkBoolOpt false;
  };

  config = mkIf enabled {
    home.packages =
      with pkgs.xfce;
      [
        (thunar.override { inherit thunarPlugins; })
      ]
      ++ (with pkgs.mate; [
        engrampa
      ]);
  };
}
