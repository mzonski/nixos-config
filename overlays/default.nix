{ inputs, ... }:
self: super: {
  peazip-gtk2 = super.callPackage ../packages/peazip-gtk2 { };

  apple-fonts = super.callPackage ../packages/apple-fonts { };

  plymouth-spinner-monochrome = super.callPackage ../packages/plymouth-spinner-monochrome { };

}
