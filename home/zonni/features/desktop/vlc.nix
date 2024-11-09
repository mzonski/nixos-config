{ pkgs, ... }:
{
  home.packages = (
    with pkgs;
    [
      vlc
      streamlink # CLI for extracting streams from various websites
    ]
  );
}
