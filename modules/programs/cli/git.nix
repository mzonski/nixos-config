{
  pkgs,
  delib,
  host,
  lib,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (delib) module singleEnableOption;
in
module {
  name = "programs.development.git";

  options = singleEnableOption true;

  home.ifEnabled = {
    programs.delta = {
      enable = true;
      options = {
        navigate = true;
        light = false;
        side-by-side = true;
        line-numbers = true;
      };
    };

    programs.git = {
      enable = true;
      package = pkgs.git;

      settings = {
        core = {
          editor = "nano"; # TODO: Use config variable
          whitespace = "fix,-indent-with-non-tab,trailing-space,cr-at-eol";
        };
        color.ui = true;
        pull.rebase = true;
        push.autoSetupRemote = true;
        merge.conflictstyle = "diff3";
        diff.colorMoved = "default";
        init.defaultBranch = "main";
        branch.sort = "committerdate";
        rerere.enabled = true;

        alias = {
          unstage = "reset HEAD --";
          last = "log -1 HEAD";
          lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
          amend = "commit --amend";
          undo = "reset --soft HEAD^";
          stashall = "stash save --include-untracked";
          pushall = "!git remote | xargs -L1 git push --all";
        };

        user = {
          name = "Maciej Zonski";
          email = "me@zonni.pl";
        };
      };

      ignores = [
        ".DS_Store"
        "*.swp"
        "*~"
        "*.log"
        "node_modules"
        "Thumbs.db"
      ];

      lfs.enable = true;

      signing = mkIf host.isDesktop {
        key = "1DE6074072F24AB36243CD7E3966358398A56CC1";
        signByDefault = true;
      };
    };

  };
}
