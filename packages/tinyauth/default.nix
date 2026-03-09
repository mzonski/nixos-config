{
  buildGoModule,
  fetchFromGitHub,
  bun2nix,
  bun,
  runCommand,
  ...
}:
let
  version = "5.0.2";

  src = fetchFromGitHub {
    owner = "steveiliop56";
    repo = "tinyauth";
    tag = "v${version}";
    hash = "sha256-i074facoWTg7+c9OdGhcOEknP/GZ6st0IIdwwvHC7IQ=";
    fetchSubmodules = true;
  };

  generatedBunNix = runCommand "tinyauth-bun-nix" { } ''
    ${bun2nix}/bin/bun2nix -l ${src}/frontend/bun.lock -o $out
  '';

  bunDeps = bun2nix.fetchBunDeps {
    bunNix = generatedBunNix;
  };
in
buildGoModule {
  pname = "tinyauth";
  inherit version src;

  subPackages = [ "cmd/tinyauth" ];

  nativeBuildInputs = [
    bun
  ];

  preBuild = ''
    export BUN_INSTALL_CACHE_DIR="${bunDeps}/share/bun-cache"

    bun install --cwd frontend --frozen-lockfile --ignore-scripts
    bun run --cwd frontend build

    mv frontend/dist internal/assets/dist
  '';

  ldflags = [
    "-s"
    "-w"
    "-X tinyauth/internal/config.Version=${version}"
  ];

  vendorHash = "sha256-cTUUjrMOtcxK8/S0h2DNZez5ELRTaSgCqo3k/tQ3584=";

  meta = {
    mainProgram = "tinyauth";
  };
}
