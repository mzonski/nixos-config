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
  inherit (pkgs) writeScript;
  inherit (lib) strings;
in
module {
  name = "programs.cli.zsh";

  options = singleEnableOption host.not.isMinimal;

  nixos.ifEnabled = {
    users.defaultUserShell = pkgs.zsh;

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
          cdgit = "cd ~/Git";
          watch = "watch ";
          gpgbye = "gpg-connect-agent updatestartuptty /bye";
          tmux = "tmux -u";
          kctx = "kubectx"; # TODO: move where relevant
          kns = "kubens";
          tf = "terraform";
          tg = "terragrunt";
          print_path = "echo $PATH | tr ':' '\n' | sort";
          docker_rm = "docker rm -f $(docker ps -aq) && docker rmi -f $(docker images -q)";
          reboot2win = "sudo systemctl reboot --boot-loader-entry=auto-windows";
          check-gpu = ''
            echo "DGPU NVIDIA" | grep "NVIDIA" && lspci -nnk | grep "NVIDIA Corporation GA104" -A 2 | grep "Kernel driver in use" &&
            echo "IGD AMD" | grep "AMD" && lspci -nnk | grep "\[Radeon Graphics\]" -A 3 | grep "Kernel driver in use" '';
          nvidia-enable = ''
            sudo virsh nodedev-reattach pci_0000_01_00_0 && 
            echo "GPU reattached" && 
            sudo rmmod vfio_pci vfio_pci_core vfio_iommu_type1 vfio && echo "VFIO drivers removed" && 
            sudo modprobe -i nvidia_drm nvidia_modeset nvidia_uvm nvidia && echo "NVIDIA drivers added"
          '';
          nvidia-disable = ''
            sudo rmmod nvidia_uvm nvidia_drm nvidia_modeset nvidia && echo "NVIDIA drivers removed" && 
            sudo modprobe -i vfio_pci vfio_pci_core vfio_iommu_type1 vfio && echo "VFIO drivers added" && 
            sudo virsh nodedev-detach pci_0000_01_00_0 && echo "GPU detached"
          '';
          gpu-processes = "lsof /dev/dri/card* | awk 'NR==1 || !seen[$1,$NF]++ {print}'";
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

          # Make sure krew works
          export PATH="$PATH:$HOME/.krew/bin"
          export EDITOR="nano"

          # Powerlevel10k instant prompt
          if [[ -r "${homeconfig.xdg.cacheHome}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
            source "${homeconfig.xdg.cacheHome}/p10k-instant-prompt-''${(%):-%n}.zsh"
          fi

          # Powerlevel10k configuration
          [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

          # Custom aliases
          alias edit='nano'
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
