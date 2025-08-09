{ lib }:
let
  inherit (lib) makeBinPath;
in
rec {
  extendPath = nixPackages: ''
    export PATH="${makeBinPath (nixPackages)}:$PATH"
  '';

  extendPathPre = extendPath;

  extendPathPost = nixPackages: ''
    export PATH="$PATH:${makeBinPath (nixPackages)}"
  '';

  requireRoot = ''
    [[ $EUID -ne 0 ]] && echo "Error: Root is required" && exit 1
  '';
}
