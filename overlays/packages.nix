{ inputs, delib, ... }:
delib.overlayModule {
  name = "overlays.local-packages";
  overlays = [
    (final: prev: {
      local = builtins.listToAttrs (
        map (path: {
          name = baseNameOf (dirOf path);
          value = prev.callPackage path {
            inherit inputs;
          };
        }) (inputs.denix.lib.umport { path = ../packages; })
      );
    })
  ];
}
