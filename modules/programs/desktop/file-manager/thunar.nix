{
  delib,
  pkgs,
  host,
  ...
}:

let
  inherit (delib) module singleEnableOption;
in
module {
  name = "programs.desktop.thunar";

  options = singleEnableOption host.isDesktop;

  home.ifEnabled =
    let
      thunarPlugins = with pkgs.xfce; [
        thunar-volman
        thunar-archive-plugin
      ];
    in
    {
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
