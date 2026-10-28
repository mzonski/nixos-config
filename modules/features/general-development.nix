{
  delib,
  pkgs,
  homeconfig,
  lib,
  ...
}:

let
  inherit (delib) module singleEnableOption;
  nodePkg = pkgs.nodejs_26;
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

      node = [
        pkgs.yarn
        pkgs.unstable.pnpm
        pkgs.node-gyp
        pkgs.node-glob
        nodePkg
      ];

      python = [
        (pkgs.python312.withPackages (
          ps: with ps; [
            xmltodict
            requests
            packaging
            pyyaml
            capstone
          ]
        ))
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

      other = with pkgs; [
        claude-code
        unstable.opencode
      ];

      npmRegistryLocation = "${homeconfig.home.homeDirectory}/.local/share/.npm-registry";
      npmConfigFile = "npm/npmrc";
      pnpmRoot = "${homeconfig.home.homeDirectory}/.local/share/pnpm";
    in
    {
      home.packages = node ++ python ++ kubernetes ++ other ++ [ dotnet-full ];

      xdg.configFile."${npmConfigFile}".text = lib.generators.toINIWithGlobalSection { } {
        globalSection = {
          prefix = npmRegistryLocation;
          update-notifier = false;
          fund = false;
        };
      };

      home.sessionPath = [
        "${homeconfig.home.homeDirectory}/.dotnet/tools/"
        "${npmRegistryLocation}/bin"
        "${pnpmRoot}/bin"
      ];

      home.sessionVariables = {
        NPM_CONFIG_USERCONFIG = "${homeconfig.xdg.configHome}/${npmConfigFile}";
        NODE_PATH = nodePkg;

        PNPM_CONFIG_GLOBAL_DIR = "${pnpmRoot}/global";
        PNPM_CONFIG_GLOBAL_BIN_DIR = "${pnpmRoot}/bin";
        PNPM_CONFIG_STATE_DIR = "${pnpmRoot}/state";
        PNPM_CONFIG_CACHE_DIR = "${pnpmRoot}/cache";
        PNPM_CONFIG_UPDATE_NOTIFIER = "false";

        DOTNET_ROOT = "${dotnet-full}/share/dotnet";
        DOTNET_PATH = "${dotnet-full}/bin/dotnet";
        DOTNET_CLI_TELEMETRY_OPTOUT = "true";

        CLAUDE_CODE_EXECUTABLE = "${pkgs.claude-code.outPath}/bin/.claude-wrapped";
      };
    };
}
