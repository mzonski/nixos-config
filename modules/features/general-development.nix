{
  delib,
  pkgs,
  homeconfig,
  ...
}:

let
  inherit (delib) module singleEnableOption;
in
module {
  name = "features.general-development";

  options = singleEnableOption false;

  nixos.ifEnabled = {
    programs.ghidra.enable = true;
  };

  home.ifEnabled =
    { myconfig, ... }:
    let
      kubernetes = [
        pkgs.unstable.kubectx
        pkgs.unstable.kubectl
        pkgs.unstable.kubernetes-helm
      ];

      node22 = [
        pkgs.yarn
        pkgs.pnpm
        pkgs.nodejs_22
        pkgs.node-gyp
        pkgs.node-glob
      ];

      python312 = [
        pkgs.python312
        pkgs.python312Packages.pip
        pkgs.python312Packages.packaging
        pkgs.python312Packages.requests
        pkgs.python312Packages.xmltodict
      ];

      script = ''
        echo test
        ls "$out"
        for i in $out/share/dotnet/sdk/*
        do
          i=$(basename $i)
          length=$(printf "%s" "$i" | wc -c)
          substring=$(printf "%s" "$i" | cut -c 1-$(expr $length - 2))
          i="$substring""00"

          echo $i

          mkdir -p $out/share/dotnet/metadata/workloads/''${i/-*}
          touch $out/share/dotnet/metadata/workloads/''${i/-*}/userlocal
        done
      '';

      sdkOverride = (
        finalAttrs: previousAttrs: {
          src = (
            previousAttrs.src.overrideAttrs (
              finalAttrs: previousAttrs: {

                postBuild = (previousAttrs.postBuild or "") + script;
              }
            )
          );
        }
      );
      dotnet-full =
        with pkgs;
        (
          with dotnetCorePackages;
          combinePackages [
            (sdk_9_0.overrideAttrs sdkOverride)
            (sdk_8_0.overrideAttrs sdkOverride)
          ]
        );

      other = with pkgs.unstable; [
        claude-code
      ];
    in
    {
      home.packages = node22 ++ python312 ++ kubernetes ++ other ++ [ dotnet-full ];

      xdg.configFile."npm/npmrc".text = ''
        update-notifier=false
      '';

      home.sessionPath = [ "${homeconfig.home.homeDirectory}/.dotnet/tools/" ];

      home.sessionVariables = {
        NPM_CONFIG_USERCONFIG = "${homeconfig.home.homeDirectory}/.config/npm/npmrc";
        DOTNET_ROOT = "${dotnet-full}/share/dotnet";
        DOTNET_PATH = "${dotnet-full}/bin/dotnet";
        DOTNET_CLI_TELEMETRY_OPTOUT = "true";
      };
    };
}
