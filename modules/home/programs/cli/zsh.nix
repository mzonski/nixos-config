{
  config,
  pkgs,
  lib,
  lib',
  ...
}:
with lib;
with lib';
let
  enabled = config.programs.zsh.enable;
  inherit (pkgs) stdenv;
in
{
  config = mkIf enabled {
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.zsh = {
      autosuggestion.enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;

      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "python"
          "pip"
          "sudo"
          "command-not-found"
          "z"
        ];
      };

      plugins = [
        {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
        {
          name = "zsh-nix-shell";
          src = pkgs.zsh-nix-shell;
          file = "share/zsh-nix-shell/nix-shell.plugin.zsh";
        }
      ];

      zplug = {
        enable = true;
        plugins = [
          {
            name = "zsh-users/zsh-syntax-highlighting";
            tags = [ "defer:2" ];
          }
          {
            name = "plugins/git";
            tags = [ "from:oh-my-zsh" ];
          }
          {
            name = "plugins/kubectl";
            tags = [ "from:oh-my-zsh" ];
          }
          {
            name = "plugins/helm";
            tags = [ "from:oh-my-zsh" ];
          }
          {
            name = "plugins/docker";
            tags = [ "from:oh-my-zsh" ];
          }
          {
            name = "plugins/cp";
            tags = [ "from:oh-my-zsh" ];
          }
          {
            name = "plugins/man";
            tags = [ "from:oh-my-zsh" ];
          }
        ];
      };
      history = {
        save = 10000000;
        size = 10000000;
        path = "${config.xdg.dataHome}/zsh/history";
      };
      shellAliases = {
        ls = if stdenv.isLinux then "ls --color" else "ls -G";
        cdgit = "cd ~/Git";
        watch = "watch ";
        gpgbye = "gpg-connect-agent updatestartuptty /bye";
        tmux = "tmux -u";
        kctx = "kubectx"; # TODO: move where relevant
        kns = "kubens";
        tf = "terraform";
        tg = "terragrunt";
      };
      initExtra = ''
        # Disable the underline for paths
        typeset -A ZSH_HIGHLIGHT_STYLES
        ZSH_HIGHLIGHT_STYLES[path]='none'

        autoload -z edit-command-line
        zle -N edit-command-line
        bindkey "^X^X" edit-command-line
        bindkey '^A' beginning-of-line
        bindkey '^E' end-of-line

        setopt PROMPT_SP

        # Make sure krew works
        export PATH="$PATH:$HOME/.krew/bin"
        export EDITOR="${config.home.sessionVariables.EDITOR}"

        # Powerlevel10k instant prompt
        if [[ -r "${config.xdg.cacheHome}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "${config.xdg.cacheHome}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi

        # Powerlevel10k configuration
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

        # Custom aliases
        alias edit='${config.home.sessionVariables.EDITOR}'
      '';
    };

    programs.direnv = {
      enable = mkDefault true;
      nix-direnv.enable = mkDefault true;
    };

    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      # Configuration written to ~/.config/starship.toml
      settings = {
        # add_newline = false;

        # character = {
        #   success_symbol = "[➜](bold green)";
        #   error_symbol = "[➜](bold red)";
        # };

        golang.symbol = " ";
        docker_context.symbol = " ";
        directory.read_only = " ";
        aws.symbol = "  ";
        git_branch.symbol = " ";
        java.symbol = " ";
        memory_usage.symbol = " ";
        nix_shell.symbol = " ";
        package.symbol = " ";
        python.symbol = " ";
        rust.symbol = " ";
        shlvl.symbol = " ";
        gcloud.symbol = " ";
        terraform.symbol = "行";
        lua.symbol = " ";
      };
    };

  };
}
