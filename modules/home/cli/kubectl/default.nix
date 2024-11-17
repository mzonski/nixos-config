{ config, options, lib, pkgs, mylib, ... }:

with lib;
with mylib;
let cfg = config.my.shell.kubectl;
in
{
  options.my.shell.kubectl = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      unstable.kubectx
      unstable.kubectl
      unstable.kubernetes-helm
    ];
  };
}
