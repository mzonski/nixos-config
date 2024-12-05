{ inputs, ... }:
final: prev:
(inputs.rust-overlay.overlays.default final prev)
// {
  apple-fonts = prev.callPackage ../packages/apple-fonts { };

  peazip-gtk2 = prev.callPackage ../packages/peazip-gtk2 { };

  nwg-clipman = prev.callPackage ../packages/nwg-clipman { };
}
