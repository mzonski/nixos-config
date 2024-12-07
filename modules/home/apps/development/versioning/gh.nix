{
  config,
  lib,
  pkgs,
  mylib,
  ...
}:

with lib;
with mylib;
let
  enabled = config.programs.gh.enable;
in
{
  config = mkIf enabled {
    programs.gh = {
      extensions = with pkgs; [ gh-markdown-preview ];
      settings = {
        version = "1";
        git_protocol = "ssh";
        prompt = "enabled";
      };
    };
  };
}
