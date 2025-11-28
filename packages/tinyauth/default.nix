{
  buildGoModule,
  fetchFromGitHub,
  bun2nix,
  bun,
  runCommand,
  ...
}:
let
  version = "4.0.1";

  src = fetchFromGitHub {
    owner = "steveiliop56";
    repo = "tinyauth";
    tag = "v${version}";
    hash = "sha256-73hyCp3TYavc37kP5rsup97NQ1iVdkouFnEppFyzOzw=";
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

  vendorHash = "sha256-rL3j681V1wtkU/Q7BrTlTRX9Lztv75/925RqhB9V+/I=";

  meta = {
    mainProgram = "tinyauth";
  };
}
