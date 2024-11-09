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

    ./features/yubikey
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
