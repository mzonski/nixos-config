{
  inputs,
  delib,
  ...
}:
delib.module (
  let
    overlay = (
      final: prev: {
        local = builtins.listToAttrs (
          map (path: {
            name = baseNameOf (dirOf path);
            value = prev.callPackage path { inherit inputs; };
          }) (inputs.denix.lib.umport { path = ../packages; })
        );
      }
    );
  in
  {
    name = "overlays.local-packages";

    nixos.always.nixpkgs.overlays = [
      overlay
    ];

    home.always.nixpkgs.overlays = [
      overlay
    ];
  }
)
