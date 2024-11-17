{ pkgs, ... }:
{
  imports = [
    ./gitkraken.nix
    ./jetbrains.nix
    ./node.nix
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
