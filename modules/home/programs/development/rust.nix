{
  config,
  lib,
  pkgs,
  lib',
  ...
}:

with lib;
with lib';
let
  cfg = config.hom.development;

  rustWithStd = pkgs.rust-bin.stable.latest.default.override {
    extensions = [ "rust-src" ];
    # targets = [ "wasm32-unknown-unknown" ];
  };
in
{
  options.hom.development = {
    rust = mkBoolOpt false;
  };

  config = mkIf cfg.rust {
    home.packages =
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
  };
}
