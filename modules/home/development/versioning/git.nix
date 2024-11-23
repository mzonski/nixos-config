{
  config,
  options,
  lib,
  pkgs,
  mylib,
  ...
}:

with lib;
with mylib;
let
  cfg = config.hom.development.versioning;
in
{
  options.hom.development.versioning.git = {
    enable = mkBoolOpt false;
    userName = mkStrOpt null;
    userEmail = mkStrOpt null;
  };

  config = mkIf cfg.git.enable {

    programs.git = {
      enable = true;
      package = pkgs.git;

      userName = cfg.git.userName;
      userEmail = cfg.git.userEmail;

      extraConfig = {
        core = {
          editor = "nano";
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
      };

      aliases = {
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        amend = "commit --amend";
        undo = "reset --soft HEAD^";
        stashall = "stash save --include-untracked";
        pushall = "!git remote | xargs -L1 git push --all";
      };

      ignores = [
        ".DS_Store"
        "*.swp"
        "*~"
        "*.log"
        "node_modules"
        "Thumbs.db"
      ];

      delta = {
        enable = true;
        options = {
          navigate = true;
          light = false;
          side-by-side = true;
          line-numbers = true;
        };
      };

      lfs.enable = true;

      # signing = {
      #   key = "your-gpg-key-id";
      #   signByDefault = true;
      # };
    };

  };
}
