{
  pkgs,
  lib,
  stdenv,
  bash,
  jq,
  hyprland,
  monitors ? {
    primary = {
      output = "DP-4";
      workspaces = [
        1
        2
        3
        4
      ];
    };
    secondary = {
      output = "HDMI-A-4";
      workspaces = [
        5
        6
        7
        8
      ];
    };
  },
}:

let
  packageName = "hypr-workspace-nav";
  # Convert monitors config to shell variables
  monitorsConfig =
    with lib;
    concatStringsSep "\n" (
      mapAttrsToList (name: monitor: ''
        ${name}_OUTPUT="${monitor.output}"
        ${name}_MIN_WORKSPACE="${toString (builtins.head monitor.workspaces)}"
        ${name}_MAX_WORKSPACE="${
          toString (builtins.elemAt monitor.workspaces ((length monitor.workspaces) - 1))
        }"
      '') monitors
    );
in
stdenv.mkDerivation {
  pname = packageName;
  version = "1";

  src = ./script.sh;

  dontUnpack = true;

  nativeBuildInputs = [ bash ];
  buildInputs = [
    jq
    hyprland
  ];

  buildPhase = ''
    # Insert monitor configuration at the start of the script
    sed -i "1a\\
    # Auto-generated monitor configuration\\
    ${monitorsConfig}" workspace-nav.sh
  '';

  installPhase = ''
    mkdir -p $out/bin
    install -Dm755 workspace-nav.sh $out/bin/${packageName}
  '';

  meta = with lib; {
    description = "Hyprland workspace navigation script with monitor-aware boundaries";
    platforms = platforms.all;
    mainProgram = packageName;
    license = licenses.mit;
    maintainers = [ ]; # Add your maintainer info if desired
  };
}
