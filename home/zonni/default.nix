{
  _inputs,
  _lib,
  _config,
  pkgs,
  ...
}:
{
  imports = [
    ./global.nix
    ./features/vscode.nix
    ./shell.nix
  ];

  home.packages = (
    with pkgs;
    [
      vscode
      cowsay
      nixfmt-rfc-style
      nil
      python312
      python312Packages.pip
      jetbrains.pycharm-professional
      jetbrains.datagrip
      gitkraken
    ]
  );
  # ++ (with unstable; [ ]);

  programs.poetry.enable = true;
}
