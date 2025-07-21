{
  inputs,
  delib,
  ...
}:
delib.module (
  let
    overlay = (
      final: prev: rec {
        local = builtins.listToAttrs (
          map (path: {
            name = baseNameOf (dirOf path);
            value = prev.callPackage path {
              inherit inputs;
              # kernel = what to put here?
            };
          }) (inputs.denix.lib.umport { path = ../packages; })
        );

        # kernelPackages = {
        #   asus-ec-sensors = prev.callPackage ../kernelPackages/asus-ec-sensors {
        #     inherit inputs;
        #   };
        # };

        # kernelPackages = {
        #   asus-ec-sensors = prev.callPackage ../kernelPackages/asus-ec-sensors {
        #     inherit inputs;
        #     # kernel is automatically provided by kernelPackages.extend
        #   };
        # };
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
