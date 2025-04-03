{ stdenv, fetchurl }:
let
  branch = "6.6";
  kversion = "6.6.84";
  pversion = "rt52";
  sha256 = "5cf2514ed8b8675ae0946b7453e94712b75050622dfb2a1f8a31cb1f30317b28";

in
{
  name = "rt-${kversion}-${pversion}";
  patch = fetchurl {
    inherit sha256;
    url = "https://www.kernel.org/pub/linux/kernel/projects/rt/${branch}/older/patch-${kversion}-${pversion}.patch.xz";
  };
}
