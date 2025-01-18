{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) makeExtensible attrValues foldr;
  inherit (modules) mapModules;

  modules = import ./modules.nix {
    inherit lib;
    self.attrs = import ./attrs.nix {
      inherit lib;
      self = { };
    };
  };

  lib' = makeExtensible (
    self:
    with self;
    mapModules ./. (
      file:
      import file {
        inherit
          self
          lib
          pkgs
          inputs
          ;
        lib' = self;
      }
    )
  );
in
lib'.extend (self: super: foldr (a: b: a // b) { } (attrValues super))
