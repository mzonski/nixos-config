{ inputs, ... }:
{
  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin

    ./packages.nix
    ./configuration.nix
  ];

}
