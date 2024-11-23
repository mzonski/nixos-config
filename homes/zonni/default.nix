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

  home.packages = (
    with pkgs;
    [
      hello
      arandr # xrandr gui config tool
      dconf-editor # dconf gui config tool
    ]
  );
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
        pcmanfm = true;
        templates = true;
      };
      maintenance = {
        bleachbit = true;
        qdirstat = true;
      };
      cli = {
        defaults = true;
        bash = true;
        bat = true;
        direnv = true;
      };
      engineering.qcad = true;
      entertainment = {
        vlc = true;
        streamlink = true;
      };
      hardware-info = true;
      image-manipulation = true;
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
      jetbrains = {
        webstorm = true;
        pycharm-professional = true;
        datagrip = true;
      };
      kubernetes = true;
      node = true;
      python3 = true;
      vscode.enable = true;
    };

    shell = {
      zsh.enable = true;
      hyprland.enable = true;
    };
    theme = {
      catpuccin.enable = true;
      fontProfiles = {
        enable = true;
        monospace = {
          name = "FiraCode Nerd Font";
          package = pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; };
        };
        regular = {
          name = "Fira Sans";
          package = pkgs.fira;
        };
      };
    };
  };

}
