# https://github.com/NixOS/nixpkgs/pull/318600/files
{
  delib,
  lib,
  pkgs,
  ...
}:

let

  inherit (delib) module;

  escape = lib.strings.escape [ ''"'' ];

  inherit (lib)
    mkIf
    mkOption
    types

    concatStrings
    mapAttrsToList
    optionalString
    ;
in
module {
  name = "hardware.block";
  options.hardware.block = {
    defaultScheduler = mkOption {
      type = with types; nullOr nonEmptyStr;
      default = null;
      description = ''
        Default block I/O scheduler.
        Unless `null`, the value is assigned through a udev rule matching all
        block devices.
      '';
      example = "kyber";
    };

    defaultSchedulerRotational = mkOption {
      type = with types; nullOr nonEmptyStr;
      default = null;
      description = ''
        Default block I/O scheduler for rotational drives (e.g. hard disks).
        Unless `null`, the value is assigned through a udev rule matching all
        rotational block devices.
        This option takes precedence over
        {option}`config.hardware.block.defaultScheduler`.
      '';
      example = "bfq";
    };

    scheduler = mkOption {
      type = with types; attrsOf nonEmptyStr;
      default = { };
      description = ''
        Assign block I/O scheduler by device name pattern.
        Names are matched using the {manpage}`udev(7)` pattern syntax:
        `*`
        :  Matches zero or more characters.
        `?`
        :  Matches any single character.
        `[]`
        :  Matches any single character specified in the brackets. Ranges are
           supported via the `-` character.
        `|`
        :  Separates alternative patterns.
        Please note that overlapping patterns may produce unexpected results.
        More complex configurations requiring these should instead be specified
        directly through custom udev rules, for example via
        [{option}`config.services.udev.extraRules`](#opt-services.udev.extraRules),
        to ensure correct ordering.
        Available schedulers depend on the kernel configuration but modern
        Linux systems typically support:
        `none`
        :  No‐operation scheduler with no re‐ordering of requests. Suitable
           for devices with fast random I/O such as NVMe SSDs.
        [`mq-deadline`](https://www.kernel.org/doc/html/latest/block/deadline-iosched.html)
        :  Simple latency‐oriented general‐purpose scheduler.
        [`kyber`](https://www.kernel.org/doc/html/latest/block/kyber-iosched.html)
        :  Simple latency‐oriented scheduler for fast multi‐queue devices
           like NVMe SSDs.
        [`bfq`](https://www.kernel.org/doc/html/latest/block/bfq-iosched.html)
        :  Complex fairness‐oriented scheduler. Higher processing overhead,
           but good interactive response, especially with slower devices.
        Schedulers assigned through this option take precedence over
        {option}`config.hardware.block.defaultScheduler` and
        {option}`config.hardware.block.defaultSchedulerRotational` but may be
        overridden by other udev rules.
      '';
      example = {
        "mmcblk[0-9]*" = "bfq";
        "nvme[0-9]*" = "kyber";
      };
    };
  };

  nixos.always =
    { cfg, ... }:
    mkIf
      (cfg.defaultScheduler != null || cfg.defaultSchedulerRotational != null || cfg.scheduler != { })
      {
        services.udev.packages = [
          (pkgs.writeTextDir "etc/udev/rules.d/98-block-io-scheduler.rules" (
            optionalString (cfg.defaultScheduler != null) ''
              SUBSYSTEM=="block", ACTION=="add|change", TEST=="queue/scheduler", ATTR{queue/scheduler}="${escape cfg.defaultScheduler}"
            ''
            + optionalString (cfg.defaultSchedulerRotational != null) ''
              SUBSYSTEM=="block", ACTION=="add|change", ATTR{queue/rotational}=="1", TEST=="queue/scheduler", ATTR{queue/scheduler}="${escape cfg.defaultSchedulerRotational}"
            ''
            + concatStrings (
              mapAttrsToList (name: sched: ''
                SUBSYSTEM=="block", ACTION=="add|change", KERNEL=="${escape name}", ATTR{queue/scheduler}="${escape sched}"
              '') cfg.scheduler
            )
          ))
        ];
      };
}
