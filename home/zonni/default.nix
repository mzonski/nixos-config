{
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
      arandr
    ]
  );
  # ++ (with unstable; [ ]);

}
