{
  buildGoModule,
  fetchFromGitHub,
  bun2nix,
  bun,
  runCommand,
  ...
}:
let
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "steveiliop56";
    repo = "tinyauth";
    tag = "v${version}";
    hash = "sha256-v/Wf3bLoDHcGmlmL9hLbtt/tBuTRAN0SDFmON82Nn0I=";
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

  vendorHash = "sha256-2sHZZ0negYHBIVzFqtRS/AUe67rrS0jcLb1iWEecMl4=";

  meta = {
    mainProgram = "tinyauth";
  };
}
