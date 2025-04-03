self: super:

let
  inherit (super)
    callPackage
    linuxPackagesFor
    recurseIntoAttrs
    ;
in
{
  # linux_rt_patch = callPackage ../packages/linuxkernel-6.6-rt/patch.nix { };
  # linux_rt = callPackage ../packages/linuxkernel-6.6-rt/kernel.nix {
  #   kernelPatches = [
  #     super.kernelPatches.bridge_stp_helper
  #     super.kernelPatches.export-rt-sched-migrate
  #     self.linux_rt_patch
  #   ];
  # };
  # linuxPackages_rt = recurseIntoAttrs (linuxPackagesFor self.linux_rt);

  fsnotifier = callPackage ../packages/fsnotifier { };
}
