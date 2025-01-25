{
  config,
  lib,
  pkgs,
  lib',
  ...
}:

let
  enabled = config.development.kubernetes.enable;

  inherit (lib') mkBoolOpt;
  inherit (lib) mkIf;
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
