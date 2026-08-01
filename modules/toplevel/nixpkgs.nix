{ delib, lib, ... }:
let
  generateNixpkgsConfig = cudaEnabled: {
    files."nixpkgs/config.nix".text = ''
      {
        cudaSupport = ${if cudaEnabled then "true" else "false"};
        allowUnfree = true;
      }
    '';
    variables."NIXPKGS_ALLOW_UNFREE" = 1;
  };
  isCudaEnabled = myconfig: myconfig.features.ai.enable == true;

in
delib.module {
  name = "nixpkgs";

  nixos.always =
    { myconfig, ... }:
    let
      cudaEnabled = isCudaEnabled myconfig;
      nixpkgsConfig = generateNixpkgsConfig cudaEnabled;
    in
    {
      environment.variables = nixpkgsConfig.variables;
      nixpkgs.config = {
        allowUnfree = true;
        cudaSupport = cudaEnabled;
      };

      nix.settings = lib.mkIf cudaEnabled {
        substituters = [
          "https://cache.nixos-cuda.org"
        ];
        trusted-public-keys = [
          "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
        ];
      };
    };
  home.always =
    { myconfig, ... }:
    let
      nixpkgsConfig = generateNixpkgsConfig (isCudaEnabled myconfig);
    in
    {
      xdg.configFile = nixpkgsConfig.files;
      home.sessionVariables = nixpkgsConfig.variables;
    };
}
