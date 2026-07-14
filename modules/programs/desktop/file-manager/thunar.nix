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
      thunarPlugins = with pkgs; [
        thunar-volman
        thunar-archive-plugin
      ];
    in
    {
      home.packages =
        with pkgs;
        [
          (thunar.override { inherit thunarPlugins; })
        ]
        ++ (with pkgs; [
          engrampa
        ]);
    };
}
