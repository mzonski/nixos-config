{ delib, pkgs, ... }:
let
  inherit (delib) singleEnableOption module;
in
module {
  name = "features.ai";

  options = singleEnableOption false;

  nixos.ifEnabled = {
    services.ollama = {
      enable = true;
      package = pkgs.unstable.ollama-cuda;
    };

    services.open-webui = {
      enable = true;
      port = 8081;
    };

    environment.systemPackages = with pkgs; [
      alpaca
    ];
  };
}
