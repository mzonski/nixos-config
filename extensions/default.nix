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
  (delib.callExtension ./extend-host-options.nix)
  (delib.callExtension ./custom-functions.nix)
  (overlays.withConfig {
    defaultTargets = [
      "nixos"
    ];
  })
])
