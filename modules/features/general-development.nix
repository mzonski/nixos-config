{ delib, pkgs, ... }:

let
  inherit (delib) module singleEnableOption;
in
module {
  name = "features.general-development";

  options = singleEnableOption false;

  home.ifEnabled =
    { myconfig, ... }:
    let
      kubernetes = with pkgs; [
        unstable.kubectx
        unstable.kubectl
        unstable.kubernetes-helm
      ];

      node22 = with pkgs; [
        nodejs_22
        node-gyp
        node-glob
      ];

      python312 = with pkgs; [
        python312
        python312Packages.pip
        python312Packages.packaging
        python312Packages.requests
        python312Packages.xmltodict
      ];

      rustWithStd = pkgs.rust-bin.stable.latest.default.override {
        extensions = [ "rust-src" ];
        # targets = [ "wasm32-unknown-unknown" ];
      };

      rust =
        [
          rustWithStd
        ]
        ++ (with pkgs; [
          gcc
          gtk4
          gtk4.dev
          graphene
          gsettings-desktop-schemas

          glib
          glib.dev
        ]);
    in
    {
      home.packages =
        node22
        #++ kubernetes
        #++ rust
        ++ python312;
    };
}
