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

    kvantum.enable = true;

    git = {
      enable = true;
      userName = "Maciej Zonski";
      userEmail = "me@zonni.pl";
    };
    gh.enable = true;
    gitkraken.enable = true;
    gitkraken.theme = "catppuccin-mocha";
  };
}
