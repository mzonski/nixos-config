{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    screenfetch # print system info
  ];
}
