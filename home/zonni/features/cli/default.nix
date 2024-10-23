{pkgs, ...}: {
  imports = [
    ./bash.nix
    ./bat.nix
    ./direnv.nix
    ./gh.nix
    ./git.nix
  ];
  home.packages = with pkgs; [
    bc # Calculator
    bottom # System viewer
    ncdu # TUI disk usage
    fd # Better find
    jq # JSON pretty printer and manipulator
    timer # To help with my ADHD paralysis

    nil # Nix LSP
    nixfmt-rfc-style # Nix formatter
    nvd # Differ
    nix-diff # Differ, more detailed
    nix-output-monitor
    nh # Nice wrapper for NixOS and HM
  ];
} 
