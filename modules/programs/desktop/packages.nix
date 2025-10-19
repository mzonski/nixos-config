{
  delib,
  pkgs,
  host,
  ...
}:
delib.module {
  name = "programs.desktop.packages";

  options = delib.singleEnableOption host.isDesktop;

  home.ifEnabled =
    let
      partitioning = with pkgs; [
        ntfsprogs
        exfatprogs
        f2fs-tools
        xfsprogs
        btrfs-progs

      ];
      fonts = with pkgs; [
        roboto
        vistafonts
        textfonts
        font-awesome
        local.apple-fonts
      ];
    in
    {
      fonts.fontconfig.enable = true;

      home.packages =
        with pkgs;
        [
          # GUI
          ## SYSTEM
          gnome-logs # System logs
          hardinfo2 # Hardware information
          qpwgraph # Pipewire manager
          gnome-font-viewer
          kdiskmark

          # COMMUNICATION
          thunderbird

          streamlink
          tauon

          ## PRODUCTIVITY
          qbittorrent-enhanced
          xfce.xfburn # Image burner
          unstable.code-cursor-fhs
          libreoffice-fresh

          ## ENGINERING
          qcad

          ## IMAGE MANIPULATION
          inkscape-with-extensions
          unstable.gimp3-with-plugins

          ## MISC
          prismlauncher # minecraft
          mate.atril # Document viewer
          unstable.furmark # GPU benchmark
          unstable.mission-center

          # CONSOLE / TUI
          bc # Calculator
          bottom # System viewer (btm)
          btop # Better top
          ncdu # Calculates space usage of files
          fd # Better find
          jq # JSON pretty printer and manipulator
          nurl # Generate Nix fetcher calls from repository URLs
          caligula # disk imaging
          powertop # check energy consumption per program

          tldr # quick man

          ## HARDWARE INFO
          fwupd
          pciutils # peek/edit PCI devices config
          clinfo
          libglvnd
          glxinfo
          vulkan-tools
          lshw

          edid-decode
          lm_sensors # fancontrol isadump isaset pwmconfig sensors sensors-conf-convert sensors-detect
          usbutils # lsusb usb-devices usbhid-dump usbreset
          gptfdisk # partitioning tools: cgdisk fixparts gdisk sgdisk
          ddrescue # data recovery tool
          efibootmgr

          ## ENCRYPTION/SIGNING
          opensc # Smart card utilities and libraries
          pcsctools # PC/SC tools for smart card operations
          ccid # Smart card driver
          yubikey-manager # Main CLI tool for YubiKey management (ykman)
          yubioath-flutter # Yubico Desktop Authenticator
          yubico-piv-tool # Specific tool for PIV operations

          ## UTILS
          timer
          qalculate-qt # kalkulator
          wireshark

          ## Rice showcase
          local.trekscii
          cmatrix

          ## SYSTEM
          curl
          wget
          tree
          glib

          ## MAINTENANCE
          bleachbit # Program to clean your computer
          qdirstat # Visualise used disk space
        ]
        ++ partitioning
        ++ fonts;
    };
}
