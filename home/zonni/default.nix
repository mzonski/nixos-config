{
  _inputs,
  _lib,
  _config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin

    ./global.nix
    ./shell.nix
  ];

  home.packages = (
    with pkgs;
    [
      hello
    ]
  );
  # ++ (with unstable; [ ]);
}
