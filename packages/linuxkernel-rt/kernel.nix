{
  lib,
  fetchurl,
  buildLinux,
  ...
}@args:
let
  branch = "6.6";
  kversion = "6.6.84";
  pversion = "rt52";
  sha256 = "7fd20721551a61db347c5ac6ca05818e24058682be4e4389dc51e88d4ac17ba7";

  # Since 20.09 this is a part of lib.kernel
  option = x: x // { optional = true; };

  yes = {
    tristate = "y";
    optional = false;
  };
  no = {
    tristate = "n";
    optional = false;
  };

  whenHelpers =
    version: with lib; {
      whenAtLeast = ver: mkIf (versionAtLeast version ver);
      whenOlder = ver: mkIf (versionOlder version ver);
      # range is (inclusive, exclusive)
      whenBetween = verLow: verHigh: mkIf (versionAtLeast version verLow && versionOlder version verHigh);
    };

  realtimeConfig =
    { version }:
    with (whenHelpers version);
    {
      EXPERT = yes; # PREEMPT_RT depends on it (in kernel/Kconfig.preempt).
      PREEMPT_RT = yes;
      PREEMPT_VOLUNTARY = lib.mkForce no; # PREEMPT_RT deselects it.
      RT_GROUP_SCHED = lib.mkForce (option no); # Removed by sched-disable-rt-group-sched-on-rt.patch.
    };

  buildLinuxRT =
    { ... }@args:
    buildLinux (
      args
      // {
        structuredExtraConfig = realtimeConfig { version = args.extraMeta.branch; };
      }
      // (args.argsOverride or { })
    );

in
buildLinuxRT (
  args
  // rec {
    version = "${kversion}-${pversion}";
    extraMeta.branch = branch;

    src = fetchurl {
      inherit sha256;
      url = "mirror://kernel/linux/kernel/v6.x/linux-${kversion}.tar.xz";
    };
  }
  // (args.argsOverride or { })
)
