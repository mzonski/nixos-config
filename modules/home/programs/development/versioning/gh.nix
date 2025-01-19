{
  config,
  lib,
  pkgs,
  ...
}:

let
  enabled = config.programs.gh.enable;
  inherit (lib) mkIf;
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
