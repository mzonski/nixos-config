{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    fzf
    ripgrep
    bat
    zsh-powerlevel10k
  ];

  programs = {
    zsh = {
      enable = true;
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

      initExtra = ''
        # Powerlevel10k instant prompt
        if [[ -r "${config.xdg.cacheHome}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "${config.xdg.cacheHome}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi

        # Powerlevel10k configuration
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

        # Custom aliases
        alias edit='${config.home.sessionVariables.EDITOR}'
      '';

      history = {
        size = 10000;
        path = "${config.xdg.dataHome}/zsh/history";
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
