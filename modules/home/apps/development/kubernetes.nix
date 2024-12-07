{
  config,
  lib,
  pkgs,
  mylib,
  ...
}:

with lib;
with mylib;
let
  enabled = config.development.kubernetes.enable;
in
{
  options.development.kubernetes = {
    enable = mkBoolOpt false;
  };

  config = mkIf enabled {
    home.packages = with pkgs; [
      unstable.kubectx
      unstable.kubectl
      unstable.kubernetes-helm
    ];
  };
}
