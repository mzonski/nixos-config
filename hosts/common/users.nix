{ pkgs, config, ... }:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  users.mutableUsers = true; # set to false after keys setup
  users.users.zonni = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = ifTheyExist [
      "audio"
      "deluge"
      "docker"
      "git"
      "i2c"
      "network"
      "plugdev"
      "video"
      "wheel"
      "wireshark"
    ];

    packages = [ pkgs.home-manager ];
  };

  security.pam.services = {
    swaylock = { };
  };
}
