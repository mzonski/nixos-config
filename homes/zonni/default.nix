{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin

    ./global.nix
    #./shell.nix

  ];

  home.packages = [
    pkgs.dconf-editor # dconf gui config tool
    pkgs.gnome-logs
  ];
  # ++ (with unstable; [ ]);

  hom = {
    apps = {
      browser.firefox = {
        enable = true;
        firefoxProfiles = false;
        rememberPasswords = true;
      };
      compression = true;
      cryptography = {
        certificate-manager = true;
        smart-card = true;
        yubikey = true;
      };
      file-manager = {
        pcmanfm = false;
        thunar = true;
        templates = true;
      };
      image-viewer.feh = true;
      maintenance = {
        bleachbit = true;
        qdirstat = true;
        buttermanager = true;
      };
      cli = {
        defaults = true;
        bash = true;
        bat = true;
        direnv = true;
        fastfetch = true;
        zsh = true;
      };
      engineering.qcad = true;
      entertainment = {
        vlc = true;
        streamlink = true;
        tauon = true;
      };
      hardware-info = true;
      image-manipulation = true;
      productivity = {
        geany = true;
        qalculate = true;
        obs = true;
      };
      terminal.kitty = true;
    };

    development = {
      versioning = {
        git = {
          enable = true;
          userName = "Maciej Zonski";
          userEmail = "me@zonni.pl";
        };
        gh = true;
        gitkraken = true;
      };
      jetbrains.toolbox = true;
      kubernetes = true;
      node = true;
      rust = true;
      python3 = true;
      vscode.enable = true;
    };

    wayland-wm = {
      hyprland = {
        enable = true;
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
          name = "FiraCode Nerd Font";
          package = pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; };
          size = 12;
        };
        regular = {
          name = "Fira Sans";
          package = pkgs.fira;
        };
      };
      wallpaper = ./wallpaper.png;
    };
  };

}
