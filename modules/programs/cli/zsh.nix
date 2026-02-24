{
  homeconfig,
  pkgs,
  delib,
  lib,
  host,
  ...
}:
let
  inherit (delib) module singleEnableOption;
in
module {
  name = "programs.cli.zsh";

  options = singleEnableOption (!host.isMinimal);

  nixos.ifEnabled = {
    users.defaultUserShell = pkgs.zsh;

    programs.command-not-found.enable = true;

    programs.zsh = {
      enable = true;
      enableCompletion = true;
    };
  };

  home.ifEnabled =
    let
      inherit (pkgs) stdenv;
      inherit (lib) mkDefault;
    in
    {
      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
      };

      home.file.".p10k-desktop.zsh".source = ./p10k/.p10k-desktop.zsh;
      home.file.".p10k-tty.zsh".source = ./p10k/.p10k-tty.zsh;

      programs.zsh = {
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
          path = "${homeconfig.xdg.dataHome}/zsh/history";
        };
        shellAliases = {
          ls = if stdenv.isLinux then "ls --color" else "ls -G";
          cdgit = "cd ~/git";
          cdnix = "cd ~/git/nixos-config";
          watch = "watch ";
          gpgbye = "gpg-connect-agent updatestartuptty /bye";
          print_path = "echo $PATH | tr ':' '\n' | sort";
          docker_rm = "docker rm -f $(docker ps -aq) && docker rmi -f $(docker images -q)";
          reboot2win = "sudo systemctl reboot --boot-loader-entry=windows_11";
          reboot2bios = "sudo systemctl reboot --boot-loader-entry=auto-reboot-to-firmware-setup";
          wipe-journal = "sudo systemctl stop systemd-journald.socket systemd-journald-dev-log.socket systemd-journald-audit.socket && sudo systemctl stop systemd-journald && sudo rm -rf /var/log/journal/* && sudo systemctl start systemd-journald";
          restart-sound = "systemctl --user restart pipewire pipewire-pulse wireplumber pipewire.socket pipewire-pulse.socket";
        };
        initContent = ''
          # Disable the underline for paths
          typeset -A ZSH_HIGHLIGHT_STYLES
          ZSH_HIGHLIGHT_STYLES[path]='none'

          autoload -z edit-command-line
          zle -N edit-command-line
          bindkey "^X^X" edit-command-line
          bindkey '^A' beginning-of-line
          bindkey '^E' end-of-line

          setopt PROMPT_SP
          export EDITOR="nano"

          if [[ -r "${homeconfig.xdg.cacheHome}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
            source "${homeconfig.xdg.cacheHome}/p10k-instant-prompt-''${(%):-%n}.zsh"
          fi

          if [[ -o interactive ]] && [[ -n "$DISPLAY" || -n "$WAYLAND_DISPLAY" ]]; then
            [[ ! -f ~/.p10k-desktop.zsh ]] || source ~/.p10k-desktop.zsh
          else
            [[ ! -f ~/.p10k-tty.zsh ]] || source ~/.p10k-tty.zsh
          fi

          textedit() {
            nohup gnome-text-editor "$@" &>/dev/null & disown
          }
        '';
      }; # TODO: FIX EDITOR

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
