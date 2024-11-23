{
  config,
  options,
  lib,
  pkgs,
  mylib,
  ...
}:

with lib;
with mylib;
let
  cfg = config.hom.apps;
in
{
  options.hom.apps = {
    compression = mkBoolOpt false;
  };

  config = mkIf cfg.compression (
    # let
    # asmc =
    #   with pkgs;
    #   stdenv.mkDerivation (finalAttrs: {
    #     pname = "asmc";
    #     version = "2.36.03";

    #     src = fetchFromGitHub {
    #       owner = "nidud";
    #       repo = "asmc";
    #       rev = "f589c02bdec744e7aa84af51cdc57ebd12eee5b8";
    #       sha256 = "sha256-WsL0i1GC5N1l0/ITiv/ZwXGeubMxNYciSNfUW+GfllI=";
    #     };

    #     makeFlags = [
    #       "-C"
    #       "source/asmc"
    #       # Fails to build with the PIE default, sadly.
    #       "pic-default=no"
    #     ];

    #     hardeningDisable = [ "pie" ];

    #     # Lots of undeclared dependencies.
    #     enableParallelBuilding = false;

    #     postPatch = ''
    #       # Unconditionally passes `-Wl,-pie` even when PIC is disabled, and
    #       # then fails to build with it.
    #       substituteInPlace source/asmc/makefile \
    #         --replace-fail 'gcc -Wl,-pie' gcc
    #     '';

    #     # `make install` hard‐codes `/usr` and `sudo`; not worth it.
    #     #
    #     # This doesn’t handle the include or library directories because we
    #     # just use this for `_7zz` and don’t install any of the libraries.
    #     # Better to fail fast if anyone needs them so they know they’ll need
    #     # to adjust this derivation.
    #     installPhase = ''
    #       runHook preInstall

    #       mkdir -p $out/bin
    #       cp source/asmc/{asmc,asmc64} $out/bin

    #       runHook postInstall
    #     '';

    #     meta = {
    #       description = "MASM‐compatible assembler";
    #       homepage = "https://github.com/nidud/asmc";
    #       changelog = "https://github.com/nidud/asmc/blob/${finalAttrs.src.rev}/source/asmc/history.txt";
    #       license = lib.licenses.gpl2Only;
    #       sourceProvenance = [ lib.sourceTypes.fromSource ];
    #       maintainers = [ lib.maintainers.jk ];
    #       platforms = lib.systems.inspect.patternLogicalAnd lib.systems.inspect.patterns.isx86 lib.systems.inspect.patterns.isLinux;
    #     };
    #   });

    # _7zz =
    #   (pkgs._7zz.override {
    #     enableUnfree = true;
    #   }).overrideAttrs
    #     (oldAttrs: {
    #       nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ asmc ];
    #     });

    # peazip = pkgs.peazip {
    #   _7zz = _7zz;
    # };

    # in
    {
      home.packages = with pkgs; [
        _7zz
        peazip
      ];
    });
}
