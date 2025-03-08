{
  delib,
  pkgs,
  ...
}:

let
  inherit (delib) module singleEnableOption;
in
module {
  name = "features.general-development";

  options = singleEnableOption false;

  home.ifEnabled =
    { myconfig, ... }:
    let
      kubernetes = [
        pkgs.unstable.kubectx
        pkgs.unstable.kubectl
        pkgs.unstable.kubernetes-helm
      ];

      node22 = [
        pkgs.yarn
        pkgs.nodejs_23
        pkgs.node-gyp
        pkgs.node-glob
      ];

      python312 = [
        pkgs.python312
        pkgs.python312Packages.pip
        pkgs.python312Packages.packaging
        pkgs.python312Packages.requests
        pkgs.python312Packages.xmltodict
      ];
    in
    {
      home.packages = node22 ++ python312 ++ kubernetes;
    };
}
