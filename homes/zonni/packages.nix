{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # GUI
    ## SYSTEM
    dconf-editor # gudconf gui config tool
    gnome-logs # System logs
    hardinfo2 # Hardware information

    # COMMUNICATION
    discord
    thunderbird

    ## ENTERTAINMENT
    vlc
    streamlink
    tauon
    qbittorrent-enhanced

    ## ENGINERING
    qcad

    ## IMAGE MANIPULATION
    inkscape-with-extensions
    gimp-with-plugins

    ## MISC

    # CONSOLE / TUI
    bc # Calculator
    bottom # System viewer (btm)
    ncdu # Calculates space usage of files
    fd # Better find
    jq # JSON pretty printer and manipulator
    nurl # Generate Nix fetcher calls from repository URLs
    caligula # disk imaging

    tldr # quick man

    ## HARDWARE INFO
    fwupd
    pciutils # peek/edit PCI devices config
    clinfo
    libglvnd
    glxinfo
    vulkan-tools
    lshw

    ## ENCRYPTION/SIGNING
    opensc # Smart card utilities and libraries
    pcsctools # PC/SC tools for smart card operations
    ccid # Smart card driver
    yubikey-manager # Main CLI tool for YubiKey management (ykman)
    yubioath-flutter # Yubico Desktop Authenticator
    yubico-piv-tool # Specific tool for PIV operations

    ## UTILS
    # holywood # i'm cool boi so i need to compile it xd
    trekscii
    timer
    qalculate-qt # kalkulator

    ## SYSTEM
    curl
    wget
    tree
    glib

    ## MAINTENANCE
    bleachbit # Program to clean your computer
    buttermanager # manage btrfs
    qdirstat # Visualise used disk space

    ## TEMP
  ];
  # ++ (with unstable; [ ]);
}
