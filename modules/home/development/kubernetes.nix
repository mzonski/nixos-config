{
  config,
  options,
  lib,
  pkgs,
  mylib,
  ...
}:

with lib;
with mylib;
let
  cfg = config.hom.development;
in
{
  options.hom.development = {
    kubernetes = mkBoolOpt false;
  };

  config = mkIf cfg.kubernetes {
    home.packages = with pkgs; [
      unstable.kubectx
      unstable.kubectl
      unstable.kubernetes-helm
    ];
  };
}
