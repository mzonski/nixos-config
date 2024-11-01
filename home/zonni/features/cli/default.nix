{ pkgs, ... }:
{
  imports = [
    ./bash.nix
    ./bat.nix
    ./direnv.nix
    ./gh.nix
    ./git.nix
    ./nix-index.nix
  ];
  home.packages = with pkgs; [
    bc # Calculator
    bottom # System viewer (btm)
    ncdu # Calculates space usage of files
    fd # Better find
    jq # JSON pretty printer and manipulator
    timer
    aha # Converts ANSI escape sequences of a unix terminal to HTML code

    nil # Nix LSP
    nixfmt-rfc-style # Nix formatter
    nvd # Differ
    nix-diff # Differ, more detailed
    nix-output-monitor
    nh # Nice wrapper for NixOS and HM

    curl
    wget
    tree
  ];
}
