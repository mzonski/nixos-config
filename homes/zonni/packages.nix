{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # GUI
    ## SYSTEM
    dconf-editor # gudconf gui config tool
    gnome-logs # gui for system logs

    # COMMUNICATION
    discord
    thunderbird

    ## ENTERTAINMENT
    vlc
    streamlink
    tauon

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
    qdirstat
    caligula # disk imaging
    qbittorrent-enhanced
  ];
  # ++ (with unstable; [ ]);
}
