{ pkgs, ... }:
{
  imports = [
    ./gitkraken.nix
    ./jetbrains.nix
    ./python.nix
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
