{ delib, config, ... }:
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
  cudaEnabled = config.hardware.nvidia.enabled;
  nixpkgsConfig = generateNixpkgsConfig (cudaEnabled);
in
delib.module {
  name = "nixpkgs";

  nixos.always = {
    environment.variables = nixpkgsConfig.variables;
    nixpkgs.config = {
      allowUnfree = true;
      cudaSupport = cudaEnabled;
    };
  };
  home.always = {
    xdg.configFile = nixpkgsConfig.files;
    home.sessionVariables = nixpkgsConfig.variables;
  };
}
