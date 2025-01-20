{ pkgs, ... }:
{
  programs = {
    firefox = {
      enable = true;
      firefoxProfiles = false;
      rememberPasswords = true;
    };
    chrome.enable = true;
    bash.enable = true;
    bat.enable = true;
    direnv.enable = true;

    file-manager = {
      enable = true;
      app = "thunar";
    };

    peazip.enable = true;
    kitty.enable = true;
    ristretto.enable = true;

    obs-studio.enable = true;
    fastfetch.enable = true;
    htop.enable = true;
    zsh.enable = true;

    geany.enable = true;
    geany.colorScheme = "catppuccin-mocha";

    git = {
      enable = true;
      userName = "Maciej Zonski";
      userEmail = "me@zonni.pl";
    };
    gh.enable = true;
    gitkraken.enable = true;
    gitkraken.theme = "catppuccin-mocha";
  };

  services.cliphist.enable = true;
  services.hypridle.enable = true;

  programs.gpg.enable = true;

  qt.enable = true;

  development.kubernetes.enable = true;

  home = {
    sessionVariables = {
      EDITOR = "nano";
    };
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };

  hom = {
    pgpKey = ./pgp.asc;

    development = {
      jetbrains.toolbox = true;
      node = true;
      rust = false;
      python3 = true;
      vscode.enable = true;
    };

    wayland-wm = {
      hyprland = {
        enable = true;
        source = "input";
      };
      panel.waybar.enable = true;
      panel.swaync.enable = true;

      idle = {
        lockEnabled = false;
        lockTimeout = 10 * 60; # 10 min
        turnOffDisplayTimeout = 5 * 60; # 5 min
        suspendTimeout = 30 * 60; # 30 min
      };
    };
    theme = {
      catpuccin.enable = true;
      fontProfiles = {
        enable = true;
        monospace = {
          name = "FiraCode Nerd Font Mono";
          package = pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; };
          size = 12;
        };
        regular = {
          name = "Fira Sans Book";
          package = pkgs.fira;
          size = 14;
        };
      };
      wallpaper = ./wallpaper.png;
    };
  };
}
