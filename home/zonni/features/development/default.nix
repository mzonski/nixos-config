{ pkgs, ... }:
{
  imports = [
    ./gitkraken.nix
    ./jetbrains.nix
    ./vscode.nix
  ];

  home.packages = (
    with pkgs;
    [
      cowsay
      gnumake
    ]
  );
}
