{ delib, pkgs, ... }:

let
  inherit (delib) module singleEnableOption;
in
module {
  name = "programs.cli.gh";

  options = singleEnableOption true;

  home.ifEnabled.programs.gh = {
    extensions = with pkgs; [ gh-markdown-preview ];
    settings = {
      version = "1";
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };
}
