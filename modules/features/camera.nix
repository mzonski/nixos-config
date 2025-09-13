{
  delib,
  config,
  pkgs,
  lib,
  host,
  ...
}:

let
  inherit (delib)
    module
    moduleOptions
    boolOption
    ;
  inherit (lib) mkMerge mkIf;
in
module {
  name = "features.camera";

  options = moduleOptions {
    enable = boolOption host.isDesktop;
    loopback.enable = boolOption false;
  };

  nixos.ifEnabled =
    { cfg, ... }:
    let
      isLoopbackEnabled = cfg.loopback.enable;
    in
    mkMerge [
      {
        environment.systemPackages = with pkgs; [
          cameractrls-gtk4
          webcamoid
        ];
      }
      (mkIf isLoopbackEnabled {
        boot.extraModulePackages = [
          config.boot.kernelPackages.v4l2loopback
        ];

        boot.kernelModules = [ "v4l2loopback" ];
        boot.kernelParams = [
          "v4l2loopback.devices=1"
          "v4l2loopback.video_nr=10"
          "v4l2loopback.card_label=\"Virtual Camera\""
          "v4l2loopback.exclusive_caps=1"
        ];
      })
    ];
}
