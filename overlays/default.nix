final: prev:
# (inputs.rust-overlay.overlays.default final prev) //
{
  apple-fonts = prev.callPackage ../packages/apple-fonts { };

  peazip-gtk2 = prev.callPackage ../packages/peazip-gtk2 { };

  nwg-clipman = prev.callPackage ../packages/nwg-clipman { };

  trekscii = prev.callPackage ../packages/trekscii { };

  discord = prev.discord.overrideAttrs (_: {
    src = builtins.fetchTarball {
      url = "https://discord.com/api/download?platform=linux&format=tar.gz"; # https://discordapp.com/api/download/canary?platform=linux&format=tar.gz
      sha256 = "18d2vnz8fbrbbyak0fc6la352020lwg9gcb634n0m6v93vyznyv0";
    };
  });
}
