{ pkgs, ... }:
{
  home.packages = (
    with pkgs;
    [
      vscode
      cowsay
      nixfmt-rfc-style
      nil
      python312
      python312Packages.pip
      gitkraken
    ]
  );
}
