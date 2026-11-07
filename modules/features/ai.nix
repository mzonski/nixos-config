{ delib, pkgs, ... }:
let
  inherit (delib) singleEnableOption module;
in
module {
  name = "features.ai";

  options = singleEnableOption false;

  nixos.ifEnabled = {
    services.ollama = {
      enable = false;
      package = pkgs.unstable.ollama-cuda;
    };

    services.open-webui = {
      enable = false;
      port = 8081;
    };

    environment.systemPackages =
      with pkgs;
      [
        #alpaca
        mcp-nixos
        local.mcp-grafana
        playwright-mcp
      ]
      ++ (with pkgs.unstable; [
        mcp-server-git
      ]);
  };
}
