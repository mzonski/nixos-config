# https://discourse.ubuntu.com/t/fine-tuning-the-ubuntu-24-04-kernel-for-low-latency-throughput-and-power-efficiency/44834
# https://github.com/musnix/musnix
{
  inputs,
  lib,
  delib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkDefault;
  inherit (delib) module boolOption strOption;
in
module {
  name = "features.low-latency";

  options.features.low-latency = {
    enable = boolOption false;
    rtos.enable = boolOption false;
    soundcardPciId = strOption "";
  };

  nixos.always = {

    imports = [
      inputs.musnix.nixosModules.musnix
    ];
  };

  nixos.ifEnabled =
    { cfg, ... }:
    {
      musnix.enable = true;
      musnix.soundcardPciId = mkIf (cfg.soundcardPciId != "") "01:00.1";

      musnix.kernel = mkIf (cfg.rtos.enable) {
        realtime = true;
        packages = pkgs.linuxPackages_rt;
      };

      boot = {
        kernel.sysctl = {
          "vm.dirty_ratio" = 5;
          "vm.dirty_background_ratio" = 5;
          "vm.swappiness" = mkDefault 10;
          "vm.compaction_proactiveness" = 0;
        };
        kernelParams = [
          "preempt=full"
          #"nohz_full=all"
        ];
      };

      powerManagement.cpuFreqGovernor = "performance";
    };
}
