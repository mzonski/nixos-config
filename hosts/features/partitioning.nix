{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gparted

    ntfsprogs
  ];
}
