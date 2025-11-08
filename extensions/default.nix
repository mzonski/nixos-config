{ delib }:
(with delib.extensions; [
  args
  (base.withConfig {
    args.enable = true;
    hosts.type.types = [
      "desktop"
      "server"
      "minimal"
    ];
  })
  (delib.callExtension ./extend-rice-options.nix)
  (overlays.withConfig {
    defaultTargets = [
      "nixos"
    ];
  })
])
