{ inputs, ... }:
self: super: {
  apple-fonts = super.callPackage ../packages/apple-fonts { };

  peazip-gtk2 = super.callPackage ../packages/peazip-gtk2 { };
}
